/*** Marching Cubes Constants and Data Arrays ***/

// Indexed by: Cube index.
// Value:      How many vertices the cube index results in.
uchar constant numVertsTable[256] = {
    0, 3, 3, 6, 3, 6, 6, 9, 3, 6, 6, 9, 6, 9, 9, 6, 3, 6, 6, 9, 6, 9, 9, 12, 6,
    9, 9, 12, 9, 12, 12, 9, 3, 6, 6, 9, 6, 9, 9, 12, 6, 9, 9, 12, 9, 12, 12, 9,
    6, 9, 9, 6, 9, 12, 12, 9, 9, 12, 12, 9, 12, 15, 15, 6, 3, 6, 6, 9, 6, 9, 9,
    12, 6, 9, 9, 12, 9, 12, 12, 9, 6, 9, 9, 12, 9, 12, 12, 15, 9, 12, 12, 15,
    12, 15, 15, 12, 6, 9, 9, 12, 9, 12, 6, 9, 9, 12, 12, 15, 12, 15, 9, 6, 9,
    12, 12, 9, 12, 15, 9, 6, 12, 15, 15, 12, 15, 6, 12, 3, 3, 6, 6, 9, 6, 9, 9,
    12, 6, 9, 9, 12, 9, 12, 12, 9, 6, 9, 9, 12, 9, 12, 12, 15, 9, 6, 12, 9, 12,
    9, 15, 6, 6, 9, 9, 12, 9, 12, 12, 15, 9, 12, 12, 15, 12, 15, 15, 12, 9, 12,
    12, 9, 12, 15, 15, 12, 12, 9, 15, 6, 15, 12, 6, 3, 6, 9, 9, 12, 9, 12, 12,
    15, 9, 12, 12, 15, 6, 9, 9, 6, 9, 12, 12, 15, 12, 15, 15, 6, 12, 9, 15, 12,
    9, 6, 12, 3, 9, 12, 12, 15, 12, 15, 9, 12, 12, 15, 15, 6, 9, 12, 6, 3, 6,
    9, 9, 6, 9, 12, 6, 3, 9, 6, 12, 3, 6, 3, 3, 0,
};

// Indexed by: Cube index.
// Value:      Each triplet is a set of edges, where a triangle consists of 
//             one vertex on each of the edges (interpolated appropriately).
#define X 255
uchar constant triTable[256][16] = {
    {X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X    },
	{0, 8, 3, X, X, X, X, X, X, X, X, X, X, X, X, X    },
	{0, 1, 9, X, X, X, X, X, X, X, X, X, X, X, X, X    },
	{1, 8, 3, 9, 8, 1, X, X, X, X, X, X, X, X, X, X    },
	{1, 2, 10, X, X, X, X, X, X, X, X, X, X, X, X, X   },
	{0, 8, 3, 1, 2, 10, X, X, X, X, X, X, X, X, X, X   },
	{9, 2, 10, 0, 2, 9, X, X, X, X, X, X, X, X, X, X   },
	{2, 8, 3, 2, 10, 8, 10, 9, 8, X, X, X, X, X, X, X  },
	{3, 11, 2, X, X, X, X, X, X, X, X, X, X, X, X, X   },
	{0, 11, 2, 8, 11, 0, X, X, X, X, X, X, X, X, X, X  },
	{1, 9, 0, 2, 3, 11, X, X, X, X, X, X, X, X, X, X   },
	{1, 11, 2, 1, 9, 11, 9, 8, 11, X, X, X, X, X, X, X },
	{3, 10, 1, 11, 10, 3, X, X, X, X, X, X, X, X, X, X },
	{0, 10, 1, 0, 8, 10, 8, 11, 10, X, X, X, X, X, X, X    },
	{3, 9, 0, 3, 11, 9, 11, 10, 9, X, X, X, X, X, X, X },
	{9, 8, 10, 10, 8, 11, X, X, X, X, X, X, X, X, X, X },
	{4, 7, 8, X, X, X, X, X, X, X, X, X, X, X, X, X    },
	{4, 3, 0, 7, 3, 4, X, X, X, X, X, X, X, X, X, X    },
	{0, 1, 9, 8, 4, 7, X, X, X, X, X, X, X, X, X, X    },
	{4, 1, 9, 4, 7, 1, 7, 3, 1, X, X, X, X, X, X, X    },
	{1, 2, 10, 8, 4, 7, X, X, X, X, X, X, X, X, X, X   },
	{3, 4, 7, 3, 0, 4, 1, 2, 10, X, X, X, X, X, X, X   },
	{9, 2, 10, 9, 0, 2, 8, 4, 7, X, X, X, X, X, X, X   },
	{2, 10, 9, 2, 9, 7, 2, 7, 3, 7, 9, 4, X, X, X, X   },
	{8, 4, 7, 3, 11, 2, X, X, X, X, X, X, X, X, X, X   },
	{11, 4, 7, 11, 2, 4, 2, 0, 4, X, X, X, X, X, X, X  },
	{9, 0, 1, 8, 4, 7, 2, 3, 11, X, X, X, X, X, X, X   },
	{4, 7, 11, 9, 4, 11, 9, 11, 2, 9, 2, 1, X, X, X, X },
	{3, 10, 1, 3, 11, 10, 7, 8, 4, X, X, X, X, X, X, X },
	{1, 11, 10, 1, 4, 11, 1, 0, 4, 7, 11, 4, X, X, X, X    },
	{4, 7, 8, 9, 0, 11, 9, 11, 10, 11, 0, 3, X, X, X, X    },
	{4, 7, 11, 4, 11, 9, 9, 11, 10, X, X, X, X, X, X, X    },
	{9, 5, 4, X, X, X, X, X, X, X, X, X, X, X, X, X    },
	{9, 5, 4, 0, 8, 3, X, X, X, X, X, X, X, X, X, X    },
	{0, 5, 4, 1, 5, 0, X, X, X, X, X, X, X, X, X, X    },
	{8, 5, 4, 8, 3, 5, 3, 1, 5, X, X, X, X, X, X, X    },
	{1, 2, 10, 9, 5, 4, X, X, X, X, X, X, X, X, X, X   },
	{3, 0, 8, 1, 2, 10, 4, 9, 5, X, X, X, X, X, X, X   },
	{5, 2, 10, 5, 4, 2, 4, 0, 2, X, X, X, X, X, X, X   },
	{2, 10, 5, 3, 2, 5, 3, 5, 4, 3, 4, 8, X, X, X, X   },
	{9, 5, 4, 2, 3, 11, X, X, X, X, X, X, X, X, X, X   },
	{0, 11, 2, 0, 8, 11, 4, 9, 5, X, X, X, X, X, X, X  },
	{0, 5, 4, 0, 1, 5, 2, 3, 11, X, X, X, X, X, X, X   },
	{2, 1, 5, 2, 5, 8, 2, 8, 11, 4, 8, 5, X, X, X, X   },
	{10, 3, 11, 10, 1, 3, 9, 5, 4, X, X, X, X, X, X, X },
	{4, 9, 5, 0, 8, 1, 8, 10, 1, 8, 11, 10, X, X, X, X },
	{5, 4, 0, 5, 0, 11, 5, 11, 10, 11, 0, 3, X, X, X, X    },
	{5, 4, 8, 5, 8, 10, 10, 8, 11, X, X, X, X, X, X, X },
	{9, 7, 8, 5, 7, 9, X, X, X, X, X, X, X, X, X, X    },
	{9, 3, 0, 9, 5, 3, 5, 7, 3, X, X, X, X, X, X, X    },
	{0, 7, 8, 0, 1, 7, 1, 5, 7, X, X, X, X, X, X, X    },
	{1, 5, 3, 3, 5, 7, X, X, X, X, X, X, X, X, X, X    },
	{9, 7, 8, 9, 5, 7, 10, 1, 2, X, X, X, X, X, X, X   },
	{10, 1, 2, 9, 5, 0, 5, 3, 0, 5, 7, 3, X, X, X, X   },
	{8, 0, 2, 8, 2, 5, 8, 5, 7, 10, 5, 2, X, X, X, X   },
	{2, 10, 5, 2, 5, 3, 3, 5, 7, X, X, X, X, X, X, X   },
	{7, 9, 5, 7, 8, 9, 3, 11, 2, X, X, X, X, X, X, X   },
	{9, 5, 7, 9, 7, 2, 9, 2, 0, 2, 7, 11, X, X, X, X   },
	{2, 3, 11, 0, 1, 8, 1, 7, 8, 1, 5, 7, X, X, X, X   },
	{11, 2, 1, 11, 1, 7, 7, 1, 5, X, X, X, X, X, X, X  },
	{9, 5, 8, 8, 5, 7, 10, 1, 3, 10, 3, 11, X, X, X, X },
	{5, 7, 0, 5, 0, 9, 7, 11, 0, 1, 0, 10, 11, 10, 0, X    },
	{11, 10, 0, 11, 0, 3, 10, 5, 0, 8, 0, 7, 5, 7, 0, X    },
	{11, 10, 5, 7, 11, 5, X, X, X, X, X, X, X, X, X, X },
	{10, 6, 5, X, X, X, X, X, X, X, X, X, X, X, X, X   },
	{0, 8, 3, 5, 10, 6, X, X, X, X, X, X, X, X, X, X   },
	{9, 0, 1, 5, 10, 6, X, X, X, X, X, X, X, X, X, X   },
	{1, 8, 3, 1, 9, 8, 5, 10, 6, X, X, X, X, X, X, X   },
	{1, 6, 5, 2, 6, 1, X, X, X, X, X, X, X, X, X, X    },
	{1, 6, 5, 1, 2, 6, 3, 0, 8, X, X, X, X, X, X, X    },
	{9, 6, 5, 9, 0, 6, 0, 2, 6, X, X, X, X, X, X, X    },
	{5, 9, 8, 5, 8, 2, 5, 2, 6, 3, 2, 8, X, X, X, X    },
	{2, 3, 11, 10, 6, 5, X, X, X, X, X, X, X, X, X, X  },
	{11, 0, 8, 11, 2, 0, 10, 6, 5, X, X, X, X, X, X, X },
	{0, 1, 9, 2, 3, 11, 5, 10, 6, X, X, X, X, X, X, X  },
	{5, 10, 6, 1, 9, 2, 9, 11, 2, 9, 8, 11, X, X, X, X },
	{6, 3, 11, 6, 5, 3, 5, 1, 3, X, X, X, X, X, X, X   },
	{0, 8, 11, 0, 11, 5, 0, 5, 1, 5, 11, 6, X, X, X, X },
	{3, 11, 6, 0, 3, 6, 0, 6, 5, 0, 5, 9, X, X, X, X   },
	{6, 5, 9, 6, 9, 11, 11, 9, 8, X, X, X, X, X, X, X  },
	{5, 10, 6, 4, 7, 8, X, X, X, X, X, X, X, X, X, X   },
	{4, 3, 0, 4, 7, 3, 6, 5, 10, X, X, X, X, X, X, X   },
	{1, 9, 0, 5, 10, 6, 8, 4, 7, X, X, X, X, X, X, X   },
	{10, 6, 5, 1, 9, 7, 1, 7, 3, 7, 9, 4, X, X, X, X   },
	{6, 1, 2, 6, 5, 1, 4, 7, 8, X, X, X, X, X, X, X    },
	{1, 2, 5, 5, 2, 6, 3, 0, 4, 3, 4, 7, X, X, X, X    },
	{8, 4, 7, 9, 0, 5, 0, 6, 5, 0, 2, 6, X, X, X, X    },
	{7, 3, 9, 7, 9, 4, 3, 2, 9, 5, 9, 6, 2, 6, 9, X    },
	{3, 11, 2, 7, 8, 4, 10, 6, 5, X, X, X, X, X, X, X  },
	{5, 10, 6, 4, 7, 2, 4, 2, 0, 2, 7, 11, X, X, X, X  },
	{0, 1, 9, 4, 7, 8, 2, 3, 11, 5, 10, 6, X, X, X, X  },
	{9, 2, 1, 9, 11, 2, 9, 4, 11, 7, 11, 4, 5, 10, 6, X    },
	{8, 4, 7, 3, 11, 5, 3, 5, 1, 5, 11, 6, X, X, X, X  },
	{5, 1, 11, 5, 11, 6, 1, 0, 11, 7, 11, 4, 0, 4, 11, X   },
	{0, 5, 9, 0, 6, 5, 0, 3, 6, 11, 6, 3, 8, 4, 7, X   },
	{6, 5, 9, 6, 9, 11, 4, 7, 9, 7, 11, 9, X, X, X, X  },
	{10, 4, 9, 6, 4, 10, X, X, X, X, X, X, X, X, X, X  },
	{4, 10, 6, 4, 9, 10, 0, 8, 3, X, X, X, X, X, X, X  },
	{10, 0, 1, 10, 6, 0, 6, 4, 0, X, X, X, X, X, X, X  },
	{8, 3, 1, 8, 1, 6, 8, 6, 4, 6, 1, 10, X, X, X, X   },
	{1, 4, 9, 1, 2, 4, 2, 6, 4, X, X, X, X, X, X, X    },
	{3, 0, 8, 1, 2, 9, 2, 4, 9, 2, 6, 4, X, X, X, X        },
	{0, 2, 4, 4, 2, 6, X, X, X, X, X, X, X, X, X, X    },
	{8, 3, 2, 8, 2, 4, 4, 2, 6, X, X, X, X, X, X, X    },
	{10, 4, 9, 10, 6, 4, 11, 2, 3, X, X, X, X, X, X, X },
	{0, 8, 2, 2, 8, 11, 4, 9, 10, 4, 10, 6, X, X, X, X },
	{3, 11, 2, 0, 1, 6, 0, 6, 4, 6, 1, 10, X, X, X, X  },
	{6, 4, 1, 6, 1, 10, 4, 8, 1, 2, 1, 11, 8, 11, 1, X },
	{9, 6, 4, 9, 3, 6, 9, 1, 3, 11, 6, 3, X, X, X, X   },
	{8, 11, 1, 8, 1, 0, 11, 6, 1, 9, 1, 4, 6, 4, 1, X  },
	{3, 11, 6, 3, 6, 0, 0, 6, 4, X, X, X, X, X, X, X   },
	{6, 4, 8, 11, 6, 8, X, X, X, X, X, X, X, X, X, X   },
	{7, 10, 6, 7, 8, 10, 8, 9, 10, X, X, X, X, X, X, X },
	{0, 7, 3, 0, 10, 7, 0, 9, 10, 6, 7, 10, X, X, X, X },
	{10, 6, 7, 1, 10, 7, 1, 7, 8, 1, 8, 0, X, X, X, X  },
	{10, 6, 7, 10, 7, 1, 1, 7, 3, X, X, X, X, X, X, X  },
	{1, 2, 6, 1, 6, 8, 1, 8, 9, 8, 6, 7, X, X, X, X    },
	{2, 6, 9, 2, 9, 1, 6, 7, 9, 0, 9, 3, 7, 3, 9, X    },
	{7, 8, 0, 7, 0, 6, 6, 0, 2, X, X, X, X, X, X, X    },
	{7, 3, 2, 6, 7, 2, X, X, X, X, X, X, X, X, X, X    },
	{2, 3, 11, 10, 6, 8, 10, 8, 9, 8, 6, 7, X, X, X, X },
	{2, 0, 7, 2, 7, 11, 0, 9, 7, 6, 7, 10, 9, 10, 7, X },
	{1, 8, 0, 1, 7, 8, 1, 10, 7, 6, 7, 10, 2, 3, 11, X },
	{11, 2, 1, 11, 1, 7, 10, 6, 1, 6, 7, 1, X, X, X, X },
	{8, 9, 6, 8, 6, 7, 9, 1, 6, 11, 6, 3, 1, 3, 6, X   },
	{0, 9, 1, 11, 6, 7, X, X, X, X, X, X, X, X, X, X   },
	{7, 8, 0, 7, 0, 6, 3, 11, 0, 11, 6, 0, X, X, X, X  },
	{7, 11, 6, X, X, X, X, X, X, X, X, X, X, X, X, X   },
	{7, 6, 11, X, X, X, X, X, X, X, X, X, X, X, X, X   },
	{3, 0, 8, 11, 7, 6, X, X, X, X, X, X, X, X, X, X   },
	{0, 1, 9, 11, 7, 6, X, X, X, X, X, X, X, X, X, X   },
	{8, 1, 9, 8, 3, 1, 11, 7, 6, X, X, X, X, X, X, X   },
	{10, 1, 2, 6, 11, 7, X, X, X, X, X, X, X, X, X, X  },
	{1, 2, 10, 3, 0, 8, 6, 11, 7, X, X, X, X, X, X, X  },
	{2, 9, 0, 2, 10, 9, 6, 11, 7, X, X, X, X, X, X, X  },
	{6, 11, 7, 2, 10, 3, 10, 8, 3, 10, 9, 8, X, X, X, X    },
	{7, 2, 3, 6, 2, 7, X, X, X, X, X, X, X, X, X, X    },
	{7, 0, 8, 7, 6, 0, 6, 2, 0, X, X, X, X, X, X, X    },
	{2, 7, 6, 2, 3, 7, 0, 1, 9, X, X, X, X, X, X, X    },
	{1, 6, 2, 1, 8, 6, 1, 9, 8, 8, 7, 6, X, X, X, X    },
	{10, 7, 6, 10, 1, 7, 1, 3, 7, X, X, X, X, X, X, X  },
	{10, 7, 6, 1, 7, 10, 1, 8, 7, 1, 0, 8, X, X, X, X  },
	{0, 3, 7, 0, 7, 10, 0, 10, 9, 6, 10, 7, X, X, X, X },
	{7, 6, 10, 7, 10, 8, 8, 10, 9, X, X, X, X, X, X, X },
	{6, 8, 4, 11, 8, 6, X, X, X, X, X, X, X, X, X, X   },
	{3, 6, 11, 3, 0, 6, 0, 4, 6, X, X, X, X, X, X, X   },
	{8, 6, 11, 8, 4, 6, 9, 0, 1, X, X, X, X, X, X, X   },
	{9, 4, 6, 9, 6, 3, 9, 3, 1, 11, 3, 6, X, X, X, X   },
	{6, 8, 4, 6, 11, 8, 2, 10, 1, X, X, X, X, X, X, X  },
	{1, 2, 10, 3, 0, 11, 0, 6, 11, 0, 4, 6, X, X, X, X },
	{4, 11, 8, 4, 6, 11, 0, 2, 9, 2, 10, 9, X, X, X, X },
	{10, 9, 3, 10, 3, 2, 9, 4, 3, 11, 3, 6, 4, 6, 3, X },
	{8, 2, 3, 8, 4, 2, 4, 6, 2, X, X, X, X, X, X, X    },
	{0, 4, 2, 4, 6, 2, X, X, X, X, X, X, X, X, X, X    },
	{1, 9, 0, 2, 3, 4, 2, 4, 6, 4, 3, 8, X, X, X, X    },
	{1, 9, 4, 1, 4, 2, 2, 4, 6, X, X, X, X, X, X, X    },
	{8, 1, 3, 8, 6, 1, 8, 4, 6, 6, 10, 1, X, X, X, X   },
	{10, 1, 0, 10, 0, 6, 6, 0, 4, X, X, X, X, X, X, X  },
	{4, 6, 3, 4, 3, 8, 6, 10, 3, 0, 3, 9, 10, 9, 3, X  },
	{10, 9, 4, 6, 10, 4, X, X, X, X, X, X, X, X, X, X  },
	{4, 9, 5, 7, 6, 11, X, X, X, X, X, X, X, X, X, X   },
	{0, 8, 3, 4, 9, 5, 11, 7, 6, X, X, X, X, X, X, X   },
	{5, 0, 1, 5, 4, 0, 7, 6, 11, X, X, X, X, X, X, X   },
	{11, 7, 6, 8, 3, 4, 3, 5, 4, 3, 1, 5, X, X, X, X   },
	{9, 5, 4, 10, 1, 2, 7, 6, 11, X, X, X, X, X, X, X  },
	{6, 11, 7, 1, 2, 10, 0, 8, 3, 4, 9, 5, X, X, X, X  },
	{7, 6, 11, 5, 4, 10, 4, 2, 10, 4, 0, 2, X, X, X, X },
	{3, 4, 8, 3, 5, 4, 3, 2, 5, 10, 5, 2, 11, 7, 6, X  },
	{7, 2, 3, 7, 6, 2, 5, 4, 9, X, X, X, X, X, X, X    },
	{9, 5, 4, 0, 8, 6, 0, 6, 2, 6, 8, 7, X, X, X, X    },
	{3, 6, 2, 3, 7, 6, 1, 5, 0, 5, 4, 0, X, X, X, X    },
	{6, 2, 8, 6, 8, 7, 2, 1, 8, 4, 8, 5, 1, 5, 8, X    },
	{9, 5, 4, 10, 1, 6, 1, 7, 6, 1, 3, 7, X, X, X, X   },
	{1, 6, 10, 1, 7, 6, 1, 0, 7, 8, 7, 0, 9, 5, 4, X   },
	{4, 0, 10, 4, 10, 5, 0, 3, 10, 6, 10, 7, 3, 7, 10, X   },
	{7, 6, 10, 7, 10, 8, 5, 4, 10, 4, 8, 10, X, X, X, X    },
	{6, 9, 5, 6, 11, 9, 11, 8, 9, X, X, X, X, X, X, X  },
	{3, 6, 11, 0, 6, 3, 0, 5, 6, 0, 9, 5, X, X, X, X   },
	{0, 11, 8, 0, 5, 11, 0, 1, 5, 5, 6, 11, X, X, X, X },
	{6, 11, 3, 6, 3, 5, 5, 3, 1, X, X, X, X, X, X, X   },
	{1, 2, 10, 9, 5, 11, 9, 11, 8, 11, 5, 6, X, X, X, X    },
	{0, 11, 3, 0, 6, 11, 0, 9, 6, 5, 6, 9, 1, 2, 10, X },
	{11, 8, 5, 11, 5, 6, 8, 0, 5, 10, 5, 2, 0, 2, 5, X },
	{6, 11, 3, 6, 3, 5, 2, 10, 3, 10, 5, 3, X, X, X, X },
	{5, 8, 9, 5, 2, 8, 5, 6, 2, 3, 8, 2, X, X, X, X    },
	{9, 5, 6, 9, 6, 0, 0, 6, 2, X, X, X, X, X, X, X    },
	{1, 5, 8, 1, 8, 0, 5, 6, 8, 3, 8, 2, 6, 2, 8, X    },
	{1, 5, 6, 2, 1, 6, X, X, X, X, X, X, X, X, X, X    },
	{1, 3, 6, 1, 6, 10, 3, 8, 6, 5, 6, 9, 8, 9, 6, X   },
	{10, 1, 0, 10, 0, 6, 9, 5, 0, 5, 6, 0, X, X, X, X  },
	{0, 3, 8, 5, 6, 10, X, X, X, X, X, X, X, X, X, X   },
	{10, 5, 6, X, X, X, X, X, X, X, X, X, X, X, X, X   },
	{11, 5, 10, 7, 5, 11, X, X, X, X, X, X, X, X, X, X },
	{11, 5, 10, 11, 7, 5, 8, 3, 0, X, X, X, X, X, X, X },
	{5, 11, 7, 5, 10, 11, 1, 9, 0, X, X, X, X, X, X, X },
	{10, 7, 5, 10, 11, 7, 9, 8, 1, 8, 3, 1, X, X, X, X },
	{11, 1, 2, 11, 7, 1, 7, 5, 1, X, X, X, X, X, X, X  },
	{0, 8, 3, 1, 2, 7, 1, 7, 5, 7, 2, 11, X, X, X, X   },
	{9, 7, 5, 9, 2, 7, 9, 0, 2, 2, 11, 7, X, X, X, X   },
	{7, 5, 2, 7, 2, 11, 5, 9, 2, 3, 2, 8, 9, 8, 2, X   },
	{2, 5, 10, 2, 3, 5, 3, 7, 5, X, X, X, X, X, X, X   },
	{8, 2, 0, 8, 5, 2, 8, 7, 5, 10, 2, 5, X, X, X, X   },
	{9, 0, 1, 5, 10, 3, 5, 3, 7, 3, 10, 2, X, X, X, X  },
	{9, 8, 2, 9, 2, 1, 8, 7, 2, 10, 2, 5, 7, 5, 2, X   },
	{1, 3, 5, 3, 7, 5, X, X, X, X, X, X, X, X, X, X    },
	{0, 8, 7, 0, 7, 1, 1, 7, 5, X, X, X, X, X, X, X    },
	{9, 0, 3, 9, 3, 5, 5, 3, 7, X, X, X, X, X, X, X    },
	{9, 8, 7, 5, 9, 7, X, X, X, X, X, X, X, X, X, X    },
	{5, 8, 4, 5, 10, 8, 10, 11, 8, X, X, X, X, X, X, X },
	{5, 0, 4, 5, 11, 0, 5, 10, 11, 11, 3, 0, X, X, X, X    },
	{0, 1, 9, 8, 4, 10, 8, 10, 11, 10, 4, 5, X, X, X, X    },
	{10, 11, 4, 10, 4, 5, 11, 3, 4, 9, 4, 1, 3, 1, 4, X    },
	{2, 5, 1, 2, 8, 5, 2, 11, 8, 4, 5, 8, X, X, X, X   },
	{0, 4, 11, 0, 11, 3, 4, 5, 11, 2, 11, 1, 5, 1, 11, X   },
	{0, 2, 5, 0, 5, 9, 2, 11, 5, 4, 5, 8, 11, 8, 5, X  },
	{9, 4, 5, 2, 11, 3, X, X, X, X, X, X, X, X, X, X   },
	{2, 5, 10, 3, 5, 2, 3, 4, 5, 3, 8, 4, X, X, X, X   },
	{5, 10, 2, 5, 2, 4, 4, 2, 0, X, X, X, X, X, X, X   },
	{3, 10, 2, 3, 5, 10, 3, 8, 5, 4, 5, 8, 0, 1, 9, X  },
	{5, 10, 2, 5, 2, 4, 1, 9, 2, 9, 4, 2, X, X, X, X   },
	{8, 4, 5, 8, 5, 3, 3, 5, 1, X, X, X, X, X, X, X    },
	{0, 4, 5, 1, 0, 5, X, X, X, X, X, X, X, X, X, X    },
	{8, 4, 5, 8, 5, 3, 9, 0, 5, 0, 3, 5, X, X, X, X    },
	{9, 4, 5, X, X, X, X, X, X, X, X, X, X, X, X, X    },
	{4, 11, 7, 4, 9, 11, 9, 10, 11, X, X, X, X, X, X, X    },
	{0, 8, 3, 4, 9, 7, 9, 11, 7, 9, 10, 11, X, X, X, X },
	{1, 10, 11, 1, 11, 4, 1, 4, 0, 7, 4, 11, X, X, X, X    },
	{3, 1, 4, 3, 4, 8, 1, 10, 4, 7, 4, 11, 10, 11, 4, X    },
	{4, 11, 7, 9, 11, 4, 9, 2, 11, 9, 1, 2, X, X, X, X },
	{9, 7, 4, 9, 11, 7, 9, 1, 11, 2, 11, 1, 0, 8, 3, X },
	{11, 7, 4, 11, 4, 2, 2, 4, 0, X, X, X, X, X, X, X  },
	{11, 7, 4, 11, 4, 2, 8, 3, 4, 3, 2, 4, X, X, X, X  },
	{2, 9, 10, 2, 7, 9, 2, 3, 7, 7, 4, 9, X, X, X, X   },
	{9, 10, 7, 9, 7, 4, 10, 2, 7, 8, 7, 0, 2, 0, 7, X  },
	{3, 7, 10, 3, 10, 2, 7, 4, 10, 1, 10, 0, 4, 0, 10, X   },
	{1, 10, 2, 8, 7, 4, X, X, X, X, X, X, X, X, X, X   },
	{4, 9, 1, 4, 1, 7, 7, 1, 3, X, X, X, X, X, X, X    },
	{4, 9, 1, 4, 1, 7, 0, 8, 1, 8, 7, 1, X, X, X, X    },
	{4, 0, 3, 7, 4, 3, X, X, X, X, X, X, X, X, X, X    },
	{4, 8, 7, X, X, X, X, X, X, X, X, X, X, X, X, X    },
	{9, 10, 8, 10, 11, 8, X, X, X, X, X, X, X, X, X, X },
	{3, 0, 9, 3, 9, 11, 11, 9, 10, X, X, X, X, X, X, X },
	{0, 1, 10, 0, 10, 8, 8, 10, 11, X, X, X, X, X, X, X    },
	{3, 1, 10, 11, 3, 10, X, X, X, X, X, X, X, X, X, X },
	{1, 2, 11, 1, 11, 9, 9, 11, 8, X, X, X, X, X, X, X },
	{3, 0, 9, 3, 9, 11, 1, 2, 9, 2, 11, 9, X, X, X, X  },
	{0, 2, 11, 8, 0, 11, X, X, X, X, X, X, X, X, X, X  },
	{3, 2, 11, X, X, X, X, X, X, X, X, X, X, X, X, X   },
	{2, 3, 8, 2, 8, 10, 10, 8, 9, X, X, X, X, X, X, X  },
	{9, 10, 2, 0, 9, 2, X, X, X, X, X, X, X, X, X, X   },
	{2, 3, 8, 2, 8, 10, 0, 1, 8, 1, 10, 8, X, X, X, X  },
	{1, 10, 2, X, X, X, X, X, X, X, X, X, X, X, X, X   },
	{1, 3, 8, 9, 1, 8, X, X, X, X, X, X, X, X, X, X    },
	{0, 9, 1, X, X, X, X, X, X, X, X, X, X, X, X, X    },
	{0, 3, 8, X, X, X, X, X, X, X, X, X, X, X, X, X    },
	{X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X    },
};
#undef X

// Indexed by: Edge number.
// Value:      Pair of vertices that the edge connects.
uchar constant edgeTable[12][2] = {
    {0, 1},
    {1, 2},
    {2, 3},
    {3, 0},
    {4, 5},
    {5, 6},
    {6, 7},
    {7, 4},
    {0, 4},
    {1, 5},
    {2, 6},
    {3, 7},
};

// Indexed by: Edge number.
// Value:      Directions towards cubes sharing the edge.
int3 edgeAdjacencyTable[12][4] = {
    { (int3)(0, 0, 0) , (int3)(0, -1, 0) , (int3)(0, 0, -1) ,(int3)(0, -1, -1) },
    { (int3)(0, 0, 0) , (int3)(1, 0, 0) ,  (int3)(0, 0, -1) ,(int3)(1, 0, -1) },
    { (int3)(0, 0, 0) , (int3)(0, 1, 0) ,  (int3)(0, 0, -1) ,(int3)(0, 1, -1) },
    { (int3)(0, 0, 0) , (int3)(-1, 0, 0) , (int3)(0, 0, -1) ,(int3)(-1, 0, -1) },
    { (int3)(0, 0, 0) , (int3)(0, -1, 0) , (int3)(0, 0, 1) , (int3)(0, -1, 1) },
    { (int3)(0, 0, 0) , (int3)(1, 0, 0) ,  (int3)(0, 0, 1) , (int3)(1, 0, 1) },
    { (int3)(0, 0, 0) , (int3)(0, 1, 0) ,  (int3)(0, 0, 1) , (int3)(0, 1, 1) },
    { (int3)(0, 0, 0) , (int3)(-1, 0, 0) , (int3)(0, 0, 1) , (int3)(-1, 0, 1) },
    { (int3)(0, 0, 0) , (int3)(-1, 0, 0) , (int3)(0, -1, 0) ,(int3)(-1, -1, 0) },
    { (int3)(0, 0, 0) , (int3)(1, 0, 0) ,  (int3)(0, -1, 0) ,(int3)(1, -1, 0) },
    { (int3)(0, 0, 0) , (int3)(1, 0, 0) ,  (int3)(0, 1, 0) , (int3)(1, 1, 0) },
    { (int3)(0, 0, 0) , (int3)(-1, 0, 0) , (int3)(0, 1, 0) , (int3)(-1, 1, 0) }
};

// Indexed by: Vertex number.
// Value:      Offset (in cube widths) from vertex zero.
int3 constant vertLocs[8] = {
    (int3)(0, 0, 0),
    (int3)(1, 0, 0),
    (int3)(1, 1, 0),
    (int3)(0, 1, 0),
    (int3)(0, 0, 1),
    (int3)(1, 0, 1),
    (int3)(1, 1, 1),
    (int3)(0, 1, 1),
};

// Cut-off to use as fluid-air boundary.
float constant isolevel = 0.5;

/*** Grid location and index conversion functions ***/

// Given the index in the array and the size of the cubic grid,
// return the 3D (x, y, z) coordinates of this point in the grid.
static int3 gridPosition(int id, int n) {
    int3 pos;
    pos.z = id % n;
    pos.y = ((id - pos.z) / n) % n;
    pos.x = (id - pos.z - n * pos.y) / (n*n);

    return pos;
}

// Given the 3D (x, y, z) coordinates of a point in the grid and the size
// of the cubic grid, return the index of this point in the grid memory.
static int gridIndex(int3 loc, int n) {
    return loc.z + loc.y * n + loc.x * (n*n);
}

/*** Kernels! ***/

// Given the grid memory and the size of the cube grid, 
// return the eight field values for a given gris position.
static void fieldValues(global float* grid, int n, int3 position, float *field) {
    for (int i = 0; i < 8; i++) {
        // The index uses a grid that is one unit larger on each side than the cube grid,
        // because there are n cubes and therefore n + 1 vertices on each edge of the grid.
        int index = gridIndex(position + vertLocs[i], n + 1);
        field[i] = grid[index];
    }
}

// Given a set of field values, compute the cube index.
static uchar cubeIndex(float* field) {
    uchar index = 0;
    if (field[0] < isolevel) index |= 1;
    if (field[1] < isolevel) index |= 2;
    if (field[2] < isolevel) index |= 4;
    if (field[3] < isolevel) index |= 8;
    if (field[4] < isolevel) index |= 16;
    if (field[5] < isolevel) index |= 32;
    if (field[6] < isolevel) index |= 64;
    if (field[7] < isolevel) index |= 128;

    return index;
}

// Interpolate between two vertices based on the field values at both.
static float3 vertexInterp(float field1, float field2, float3 v1, float3 v2) {
    float alpha = (isolevel - field1) / (field2 - field1);
    return alpha * v1 + (1 - alpha) * v2;
}

// Compute the normal vector of a triangle on three vertices.
// All returned normals are normalized, i.e. of unit length.
static float3 getNormal(float3 v1, float3 v2, float3 v3) {
    // Find two vectors along the triangle edges.
    float4 vec1, vec2;
    vec1.xyz = v1 - v2;
    vec2.xyz = v1 - v3;

    return normalize(cross(vec1, vec2)).xyz;
}

// Given the field for the cube corners and an edge number,
// returns the vertex location for the vertex on that edge,
// doing interpolation between field values as necessary.
static float3 vertex(float* field, int edge) {
    int idx1 = edgeTable[edge][0];
    int idx2 = edgeTable[edge][1];
    float field1 = field[idx1];
    float field2 = field[idx2];

    // Casting int3 to float3 does not work!
    float3 vert1 = (float3) (vertLocs[idx1].x, vertLocs[idx1].y, vertLocs[idx1].z) ;
    float3 vert2 = (float3) (vertLocs[idx2].x, vertLocs[idx2].y, vertLocs[idx2].z) ;
    return vertexInterp(field1, field2, vert1, vert2);
}

// Compute the number of vertices that each cube will output.
// For each cube, this will store a multiple of three, e.g. 3 vertices means one triangle.
kernel void numVertices(int n,                     // Size of the grid on a side, in cubes.
                        global float *grid,        // Field values on the grid.
                        global int *numVerts       // Output: number of vertices each cube will output.
                       ) {
    // Compute the cube index.
    int id = get_global_id(0);
    int3 position = gridPosition(id, n);
    float field[8];
    fieldValues(grid, n, position, field);
    uchar index = cubeIndex(field);

    // Write output.
    numVerts[id] = numVertsTable[index];
}

// Compute vertex locations and face normal for each triangle.
// Each work group handles a single triangle.
kernel void generateTriangles(
        int n,                     // Size of the grid on a side, in cubes.
        global float *grid,        // Field values on the grid.
        global int *cubeId,        // Which cube to operate on.
        global int *triangleId,    // Which triangle in this cube to operate on (0 through 15).
        global float3 *v1s,        // Output: First  vertex of resulting triangle.
        global float3 *v2s,        // Output: Second vertex of resulting triangle.
        global float3 *v3s,        // Output: Third  vertex of resulting triangle.
        global float3 *normals     // Output: Face normal for the resulting triangle (normalized).
        ) {
    int id = get_global_id(0);

    int cube = cubeId[id];
    int tri  = triangleId[id];

    // Recalculate the cube index.
    float field[8];
    int3 position = gridPosition(cube, n);
    fieldValues(grid, n, position, field);
    uchar index = cubeIndex(field);

    // Figure out the edges the triangle is on.
    int e1 = triTable[index][tri * 3];
    int e2 = triTable[index][tri * 3 + 1];
    int e3 = triTable[index][tri * 3 + 2];

    // Compute the vertices for the triangle.
    float3 v1 = vertex(field, e1);
    float3 v2 = vertex(field, e2);
    float3 v3 = vertex(field, e3);

    // Compute the triangle face normal.
    float3 normal = getNormal(v1, v2, v3);

    // Write outputs.
    v1s[id] = v1;
    v2s[id] = v2;
    v3s[id] = v3;
    normals[id] = normal;
}
