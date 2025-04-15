local res = { name = [[default]], dctbl = {}, symmap = {}, map = { plain = {} } };
res.map["ralt"] = {};
res.map["ralt"][27] = "~";
res.map["lshift"] = {};
res.map["lshift"][41] = "~";
res.map["plain"] = {};
res.map["plain"][43] = "\\";
res.symmap[58] = "ESCAPE";
return res;
