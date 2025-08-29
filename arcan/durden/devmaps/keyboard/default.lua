local res = { name = [[default]], dctbl = {}, symmap = {}, map = { plain = {}, lshift = {}, ralt = {} } };
res.map["ralt"][27] = "~";
res.map["lshift"][41] = "~";
res.map["plain"][43] = "\\";
res.symmap[58] = "ESCAPE";
return res;
