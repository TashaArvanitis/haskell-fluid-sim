#define X_COMPONENT 0
#define Y_COMPONENT 1
#define Z_COMPONENT 2

typedef uchar component;

// Indexed by component. Figure out how much to shift from the middle of its
// cube to get to the position of velocity component.
static float3 grid_shifts[3] = {
    (float3)(-0.5, 0.0, 0.0),
    (float3)(0.0, -0.5, 0.0),
    (float3)(0.0, 0.0, -0.5)
};

// Time step of the simulation
static float dt = 0.01; // seconds

static float cell_width = 1; // arbitrary units (cell units)


/*** Grid location and index conversion functions ***/

static float3 velocity(
    read_only  image3d_t vx,
    read_only  image3d_t vy,
    read_only  image3d_t vz,
    float3 pos) {

    // Sampler to read from images as 3D float arrays.
    // We clamp to edge for the sake of interpolation: if we access outside the
    // boundaries, we simply want to use the values within the boundaries.
    sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE |
                        CLK_ADDRESS_CLAMP_TO_EDGE |
                        CLK_FILTER_LINEAR;

    float3 vel;
    vel.x = read_imagef(v, sampler, (float4)(pos.x + 0.5, pos.y, pos.z, 0)).w;
    vel.y = read_imagef(v, sampler, (float4)(pos.x, pos.y + 0.5, pos.z, 0)).w;
    vel.z = read_imagef(v, sampler, (float4)(pos.x, pos.y, pos.z + 0.5, 0)).w;
    return vel;
}

// Single-component velocity function
static float3 read_v(
    read_only  image3d_t v,
    float3 pos) {

    // Sampler to read from images as 3D float arrays.
    // We clamp to edge for the sake of interpolation: if we access outside the
    // boundaries, we simply want to use the values within the boundaries.
    sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE |
                        CLK_ADDRESS_CLAMP_TO_EDGE |
                        CLK_FILTER_LINEAR;

    return read_imagef(v, sampler, (float4)(pos.x, pos.y, pos.z, 0)).w;
}

// Single-component boolean image read function
static bool read_b(
    read_only  image3d_t vec,
    int x, int y, int z) {

    // Sampler to read from images as 3D bool arrays.
    // We clamp to the border color. In order to make the border color true, use CL_R;
    // in order to make the border color false, use CL_A.
    sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE |
                        CLK_ADDRESS_CLAMP |
                        CLK_FILTER_LINEAR;

    return read_imagei(vec, sampler, (int4)(x, y, z, 0)).w;
}

static void write_out(
    write_only  image3d_t img,
    float value) {

    int i = get_global_id(0);
    int j = get_global_id(1);
    int k = get_global_id(2);

    write_imagef(img, (int4)(i, j, k, 0), (float4)(0, 0, 0, value));
}

/*** Kernels ***/

// Semi-Lagrangian advection step of the simulation.
kernel void advect(
        int n,                             // Side length of the cube grid.
        component comp,                    // Which component to advect.
        read_only  image3d_t vx,           // X-coordinate velocities on faces (n+1 on each side)
        read_only  image3d_t vy,           // Y-coordinate velocities
        read_only  image3d_t vz,           // Z-coordinate velocities
        write_only image3d_t advected      // Advected velocities (output).
        ) {
    // (i, j, k) is the center of cube we're looking at.
    int i = get_global_id(0);
    int j = get_global_id(1);
    int k = get_global_id(2);
 
    // 1. Find location of the face center.
    float3 x = (float3)(i, j, k) + grid_shifts[comp];

    // 2. Get velocity at face center we're interested in.
    float3 vel = velocity(vx, vy, vz, x);
 
    // 3. Find x_mid (middle point for RK2).
    float3 x_mid = x - 0.5 * dt * vel;

    // 4. Evaluate velocity at x_mid via interpolation.
    float3 vel_mid = velocity(vx, vy, vz, x_mid);

    // 5. Find x_prev (point at previous time step).
    float3 x_prev = x - dt * vel_mid;

    // 6. Evaluate velocity component at x_prev.
    float3 vel_prev = velocity(vx, vy, vz, x_prev);

    float out;
    switch (comp) {
        case X_COMPONENT: out = vel_prev.x;
            break;
        case Y_COMPONENT: out = vel_prev.y;
            break;
        case Z_COMPONENT: out = vel_prev.z;
            break;
    }

    write_out(advected, out);
}

// Deal with body forces. For now, we only use/care about gravity
kernel void body_forces(
        read_only  image3d_t vz,           // Z-coordinate velocities
        write_only image3d_t new_vz        // Force-affected velocities (output).
        ) {
    
    float gravity = -9.8; // Eventually probably multiply by some scaling constant
                          // to make this sensible

    // Get position of the cube we care about: (i, j, k) is the center
    int i = get_global_id(0);
    int j = get_global_id(1);
    int k = get_global_id(2);

    // Get the z velocity
    float vel = read_v(vz, (float3)(i, j, k));

    // And write the output
    write_out(new_vz, vel + gravity * dt);
}

// Project
kernel void project(
        int n,                             // Side length of the cube grid.
        read_only  image3d_t vx,           // X-coordinate velocities on faces (n+1 on each side)
        read_only  image3d_t vy,           // Y-coordinate velocities
        read_only  image3d_t vz,           // Z-coordinate velocities
        read_only  image3d_t is_solid,     // boolean image - 0 for non-solid, 1 for solid
                                           // should be of type CL_A to make off-grid cells not solids.
        read_only  image3d_t is_air,       // boolean image - 0 for non-air, 1 for air
                                           // should be of type CL_R to make off-grid cells air.
        write_only image3d_t b_mem,        // The b vector, which includes divergences
        write_only image3d_t A_diag_mem,   // "A" matrix diagonal entry for each cell.
        write_only image3d_t A_xplus_mem,  // "A" matrix entry in the positive x for each cell.
        write_only image3d_t A_yplus_mem,  // "A" matrix entry in the positive y for each cell.
        write_only image3d_t A_zplus_mem   // "A" matrix entry in the positive z for each cell.
        ) {
    int i = get_global_id(0);
    int j = get_global_id(1);
    int k = get_global_id(2);

    // Compute b (divergences + modifications for boundaries ??)
    // Use finite differences for divergence
    float xminus = read_v(vx, (float3)(i, j, k));
    float yminus = read_v(vy, (float3)(i, j, k));
    float zminus = read_v(vz, (float3)(i, j, k));
    float xplus  = read_v(vx, (float3)(i + 1, j, k));
    float yplus  = read_v(vy, (float3)(i, j + 1, k));
    float zplus  = read_v(vz, (float3)(i, j, k + 1));

    float dx = xplus - xminus;
    float dy = yplus - yminus;
    float dz = zplus - zminus;

    float divergence = (dx + dy + dz) / cell_width;

    // Account for motion of solids neighboring this cell
    // Look at neighbors, see if they're solid. If they are, add a term to b
    float b = -divergence;
    int num_solid = 0;
    float solid_vel = 0;
    bool xminus_solid = read_b(is_solid, i - 1, j, k);
    b +=  xminus_solid * (xminus - solid_vel);
    num_solid += xminus_solid;

    bool xplus_solid = read_b(is_solid, i + 1, j, k);
    b +=  xplus_solid * (xplus  - solid_vel);
    num_solid += xplus_solid;

    bool yminus_solid = read_b(is_solid, i, j - 1, k);
    b +=  yminus_solid * (yminus - solid_vel);
    num_solid += yminus_solid;

    bool yplus_solid = read_b(is_solid, i, j + 1, k);
    b +=  yplus_solid * (yplus  - solid_vel);
    num_solid += yplus_solid;

    bool zminus_solid = read_b(is_solid, i, j, k - 1);
    b +=  zminus_solid * (zminus - solid_vel);
    num_solid += zminus_solid;

    bool zplus_solid = read_b(is_solid, i, j, k + 1);
    b +=  zplus_solid * (zplus  - solid_vel);
    num_solid += zplus_solid;

    b /= cell_width;

    float A_scale = dt / (fluid_density * cell_width * cell_width);
    int A_diag  = A_scale * (6 - num_solid);
    int A_xplus = read_b(is_air, i + 1, j, k) || xplus_solid ? 0 : -A_scale;
    int A_yplus = read_b(is_air, i, j + 1, k) || yplus_solid ? 0 : -A_scale;
    int A_zplus = read_b(is_air, i, j, k + 1) || zplus_solid ? 0 : -A_scale;

    write_out(b_mem,       b);
    write_out(A_diag_mem,  A_diag);
    write_out(A_xplus_mem, A_xplus);
    write_out(A_yplus_mem, A_yplus);
    write_out(A_zplus_mem, A_zplus);
}

