testCases = {...
    {'tfjigsaw-1', @(fname, dest) JigsawSep(fname, dest)}...
    {'tfjigsaw-2', @(fname, dest) JigsawSep(fname, dest,"v2",true)}...
    {'tfjigsaw-3', @(fname, dest) JigsawSep(fname, dest,"p",4)}...
    {'tfjigsaw-4', @(fname, dest) JigsawSep(fname, dest,"r2",1.03)}...
    {'tfjigsaw-5', @(fname, dest) JigsawSep(fname, dest,"r1",0.85,"r2",1.05,"p",2)}...
    {'tfjigsaw-6', @(fname, dest) JigsawSep(fname, dest,"r1",0.88,"r2",0.89)}...
    {'tfjigsaw-7', @(fname, dest) JigsawSep(fname, dest,"r1",0.85,"r2",1.05,"p",2,"v2",true)}...
    {'tfjigsaw-8', @(fname, dest) JigsawSep(fname, dest,"r1",0.85,"r2",1.05,"p",5,"v2",true)}...
    {'tfjigsaw-9', @(fname, dest) JigsawSep(fname, dest,"r1",0.85,"r2",1.05,"p",8,"v2",true)}...
};
