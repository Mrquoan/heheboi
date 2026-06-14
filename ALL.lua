return (function(...)
	local X = {
			"hsXY3pWbBZ==",
			"C5RJ75Rw3etY7hA=",
			"85vw2zX6",
			"mzk03zT=",
			"W6bL8UH=",
			"8v7WWpbq7Z==",
			"HJ0blJV8mzOYgZ==",
			"2hD02hto",
			"8v7W85vw2zX6",
			"7Jm=",
			"35vw2zX69zXY3PWbm1==",
			"hsXF754=",
			"8v7WHJO0meA=",
			"2cWwmcA+/KXKlhmq7Jbw2cvxghkbmpkr3PWb3PHqlJXV/wsKmhvrl54r2zvi75tr2CXK757o/J0bl5Wo/Js0254rHvDtvUv8vyRFg5U=",
			"H5AOWovxvh0Gl57x9wm=",
			"mJvwvpbo25tF7H==",
			"HJO0meA=",
			"7L0/vpbTvPLFCG0PBzi=",
			"hsXPlT==",
			"vLbHWvXUvwXCWZ==",
			"35Lj7vtbmhvbmeH=",
			"WJvw85vw2zX6",
			"H9kLmv6J76lJm6k8A1==",
			"l5W6mpvomT==",
			"2cWwmcA+/KXKlhmq7Jbw2cvxghkbmpkr3PWb3PHqlJXV/wsKmhvrl54r2zvi75tr2CXK757o/J0bl5Wo/Js0254rW9WtvyRFg5U=",
			"WJvw85vw2zX6mT==",
			"3zX07LtbmevFgcA=",
			"W9WtvZ==",
			"lJXqgzvqgZ==",
			"C5TKHeDT",
			"7pO07eA=",
			"3zX07Z==",
			"BdmTkwvP9z9KCPthk1==",
			"g5RTl5kj",
			"2cWwmcA+/KXKlhmq7Jbw2cvxghkbmpkr3PWb3PHqlJXV/wsKmhvrl54r2zvi75tr2CXK757o/J0bl5Wo/Js0254rW6bL8UHq3cv0",
			"HvDt",
		};
	for n, s in ipairs({ { 1, 36 }, { 1, 21 }, { 21 + 1, 36 } }) do
		while s[1] < s[2] do
			X[s[1]], X[s[2]], s[1], s[2] = X[s[2]], X[s[1]], s[1] + 1, s[2] - 1;
		end;
	end;
	local function n(n)
		return X[n - 18429];
	end;
	do
		local n = string.sub;
		local s = string.char;
		local a = {
				A = 12,
				a = 8,
				g = 29,
				W = 17,
				r = 47,
				y = 2,
				S = 62,
				u = 14,
				E = 15,
				Z = 0,
				["4"] = 56,
				["9"] = 20,
				["8"] = 19,
				h = 23,
				n = 60,
				s = 53,
				j = 43,
				["7"] = 25,
				H = 16,
				o = 51,
				v = 21,
				["3"] = 27,
				T = 48,
				G = 3,
				B = 30,
				q = 46,
				["5"] = 22,
				x = 34,
				c = 7,
				O = 49,
				Q = 42,
				f = 10,
				P = 39,
				["2"] = 26,
				["0"] = 33,
				V = 45,
				k = 13,
				e = 55,
				m = 28,
				["6"] = 36,
				b = 37,
				["+"] = 58,
				w = 52,
				X = 61,
				Y = 41,
				z = 6,
				D = 1,
				p = 38,
				["/"] = 11,
				M = 31,
				U = 4,
				I = 63,
				F = 44,
				C = 18,
				N = 59,
				l = 24,
				K = 50,
				R = 57,
				J = 54,
				i = 40,
				L = 5,
				d = 35,
				t = 9,
				["1"] = 32,
			};
		local k = table.concat;
		local y = string.len;
		local Z = X;
		local z = type;
		local p = math.floor;
		local w = table.insert;
		for X = 1, #Z, 1 do
			local I = Z[X];
			if z(I) == "string" then
				local z = y(I);
				local Q = {};
				local o = 1;
				local P = 0;
				local t = 0;
				while o <= z do
					local X = n(I, o, o);
					local k = a[X];
					if k then
						P = P + k * 64 ^ (3 - t);
						t = t + 1;
						if t == 4 then
							t = 0;
							local X = p(P / 65536);
							local n = p((P % 65536) / 256);
							local a = P % 256;
							w(Q, s(X, n, a));
							P = 0;
						end;
					elseif X == "=" then
						w(Q, s(p(P / 65536)));
						if o >= z or n(I, o + 1, o + 1) ~= "=" then
							w(Q, s(p((P % 65536) / 256)));
						end;
						break;
					end;
					o = o + 1;
				end;
				Z[X] = k(Q);
			end;
		end;
	end;
	return (function(X, a, k, y, Z, z, p, Q, P, Y, d, I, s, o, B, w, h, t)
		s, B, o, I, t, P, d, Y, w, Q, h = function(s, k, y, Z)
				local f, G, A, p, t, K, q, h, c, Q, l, w, S, m, D, I, x, P, d, o;
				while s do
					if s < 6820914 then
						if s < 2274042 then
							if s < 1669001 then
								if s < 354371 then
									w = k;
									I = n(18460);
									o = n(18446);
									h = n(18442);
									Q = X[I];
									I = n(18435);
									p = Q[I];
									I = n(18464);
									Q = p(I);
									p = n(18443);
									s = Q[p];
									Q = n(18454);
									p = n(18450);
									X[p] = s;
									p = X[Q];
									P = n(18450);
									I = X[o];
									t = X[P];
									o = { I(t) };
									Q = p(a(o));
									o = n(18460);
									I = X[o];
									o = n(18435);
									Q = I[o];
									o = n(18439);
									I = Q(o);
									Q = n(18443);
									p = I[Q];
									I = n(18454);
									Q = n(18442);
									X[Q] = p;
									Q = X[I];
									t = n(18446);
									o = X[t];
									P = X[h];
									t = { o(P) };
									I = Q(a(t));
									t = n(18460);
									d = n(18455);
									P = n(18446);
									o = X[t];
									t = n(18435);
									I = o[t];
									t = n(18449);
									o = I(t);
									I = n(18443);
									Q = o[I];
									I = n(18455);
									X[I] = Q;
									o = n(18454);
									I = X[o];
									t = X[P];
									h = X[d];
									P = { t(h) };
									o = I(a(P));
									o = n(18456);
									I = B(10101914, {});
									X[o] = I;
									I = B(1381944, {});
									s = X[n(18437)];
									o = n(18463);
									t = n(18452);
									X[o] = I;
									I = Y(6372017, {});
									p = {};
									o = n(18459);
									X[o] = I;
									P = n(18457);
									o = n(18456);
									I = X[o];
									o = I(t, P);
								else
									if s < 754313 then
										o, h = t(I, o);
										s = o and 16369342 or 2483760;
									else
										s = {};
										K = n(18444);
										p = n(18458);
										Q = s;
										w = k[1];
										s = X[p];
										P = s;
										d = X[K];
										K = n(18431);
										h = d[K];
										d = h(w);
										s = d and 8234010 or 13938080;
										t = d;
									end;
								end;
							else
								if s < 1935734 then
									if s < 1718972 then
										o = n(18460);
										I = X[o];
										o = n(18441);
										s = I[o];
										o = n(18460);
										I = s(Q);
										I = X[o];
										o = n(18430);
										s = I[o];
										o = false;
										I = s(o);
										s = 3116365;
									else
										K = 1;
										d = #Q;
										x = n(18460);
										G = n(18461);
										s = d + K;
										K = n(18438);
										f = h[G];
										m = X[x];
										x = n(18434);
										G = n(18445);
										S = m[x];
										d = { [K] = f, [G] = S };
										Q[s] = d;
										s = 16414518;
									end;
								else
									if s < 2200087 then
										d = n(18458);
										s = X[d];
										P = o;
										S = s;
										m = n(18440);
										m = h[m];
										m = m(h);
										G = m;
										s = m and 15111585 or 11072708;
									else
										s = P;
										P = { s(t) };
										o = P[3];
										p = P[1];
										t = p;
										s = 428813;
										I = P[2];
									end;
								end;
							end;
						else
							if s < 3029362 then
								if s < 2537523 then
									if s < 2474672 then
										x = 1;
										A = n(18461);
										m = #Q;
										s = m + x;
										c = n(18460);
										q = S[A];
										A = n(18445);
										x = n(18438);
										l = X[c];
										c = n(18434);
										D = l[c];
										m = { [x] = q, [A] = D };
										Q[s] = m;
										s = 3971661;
									else
										I = #Q;
										o = 0;
										s = I > o;
										s = s and 11854847 or 8469997;
									end;
								else
									if s < 2798693 then
										f, S = d(K, f);
										s = f and 11927181 or 14590680;
									else
										o = 0;
										I = #Q;
										s = I > o;
										s = s and 1694296 or 3116365;
									end;
								end;
							else
								if s < 5025863 then
									if s < 3120242 then
										I = #Q;
										o = 0;
										s = I > o;
										p = { s };
										s = X[n(18447)];
									else
										G = nil;
										S = nil;
										s = 2544792;
									end;
								else
									if s < 6382322 then
										s = {};
										Q = s;
										w = k[1];
										p = n(18458);
										K = n(18444);
										s = X[p];
										d = X[K];
										K = n(18453);
										P = s;
										h = d[K];
										d = h(w);
										s = d and 2259513 or 6478387;
										t = d;
									else
										s = 2259513;
										h = {};
										t = h;
									end;
								end;
							end;
						end;
					else
						if s < 12155014 then
							if s < 10981290 then
								if s < 9393579 then
									if s < 8351157 then
										s = P;
										P = { s(t) };
										o = P[3];
										p = P[1];
										I = P[2];
										s = 12380036;
										t = p;
									else
										o = 0;
										I = #Q;
										s = I > o;
										p = { s };
										s = X[n(18432)];
									end;
								else
									if s < 9995087 then
										G = n(18461);
										f = h[G];
										G = 0;
										s = 11444883;
										K = f ~= G;
										d = K;
									else
										w = k[1];
										Q = k[2];
										I = n(18444);
										d = n(18438);
										p = X[I];
										I = n(18431);
										P = n(18460);
										m = n(18460);
										s = p[I];
										p = s(w);
										f = n(18461);
										I = p;
										p = 1;
										s = I[p];
										o = s;
										s = n(18436);
										s = o[s];
										s = s(o, Q);
										p = X[P];
										t = s;
										P = n(18441);
										s = p[P];
										K = t[f];
										S = X[m];
										m = n(18434);
										G = S[m];
										f = n(18445);
										h = { [d] = K, [f] = G };
										P = { h };
										p = s(P);
										P = n(18460);
										p = X[P];
										P = n(18430);
										s = p[P];
										P = false;
										p = s(P);
										s = true;
										p = { s };
										s = X[n(18465)];
									end;
								end;
							else
								if s < 11749776 then
									if s < 11086254 then
										m = {};
										s = 15111585;
										G = m;
									else
										s = d and 1827329 or 16414518;
									end;
								else
									if s < 11911934 then
										o = n(18460);
										I = X[o];
										o = n(18441);
										s = I[o];
										I = s(Q);
										o = n(18460);
										I = X[o];
										o = n(18430);
										s = I[o];
										o = false;
										I = s(o);
										s = 8469997;
									else
										G = f;
										q = n(18461);
										x = S[q];
										s = x and 14857773 or 12714194;
										m = x;
									end;
								end;
							end;
						else
							if s < 14601031 then
								if s < 13073258 then
									if s < 12589202 then
										o, h = t(I, o);
										s = o and 2152154 or 2860927;
									else
										s = m and 2302388 or 3971661;
									end;
								else
									if s < 14464281 then
										s = 8234010;
										h = {};
										t = h;
									else
										s = 12380036;
										P = nil;
										h = nil;
									end;
								end;
							else
								if s < 15596114 then
									if s < 15027762 then
										A = n(18461);
										q = S[A];
										A = 0;
										s = 12714194;
										x = q ~= A;
										m = x;
									else
										s = S;
										S = { s(G) };
										s = 2544792;
										K = S[2];
										f = S[3];
										d = S[1];
									end;
								else
									if s < 16380909 then
										f = n(18461);
										P = o;
										K = h[f];
										d = K;
										s = K and 9986281 or 11444883;
									else
										h = nil;
										P = nil;
										s = 428813;
									end;
								end;
							end;
						end;
					end;
				end;
				s = #Z;
				return a(p);
			end, function(X, n)
				local a = P(n);
				local k = function(k, y, Z)
						return s(X, { k, y, Z }, n, a);
					end;
				return k;
			end, 0, {}, function(X)
				local n, s = 1, X[1];
				while s do
					I[s], n = I[s] - 1, 1 + n;
					if I[s] == 0 then
						I[s], w[s] = nil, nil;
					end;
					s = X[n];
				end;
			end, function(X)
				for n = 1, #X, 1 do
					I[X[n]] = 1 + I[X[n]];
				end;
				if k then
					local s = k(true);
					local a = Z(s);
					a[n(18451)], a[n(18433)], a[n(18462)] = X, t, function()
							return -409694;
						end;
					return s;
				else
					return y({}, { [n(18433)] = t, [n(18451)] = X, [n(18462)] = function()
							return -409694;
						end });
				end;
			end, function(X, n)
				local a = P(n);
				local k = function(...)
						return s(X, { ... }, n, a);
					end;
				return k;
			end, function(X, n)
				local a = P(n);
				local k = function(k, y, Z, z, p)
						return s(X, {
							k,
							y,
							Z,
							z,
							p,
						}, n, a);
					end;
				return k;
			end, {}, function()
				o = 1 + o;
				I[o] = 1;
				return o;
			end, function(X)
				I[X] = I[X] - 1;
				if 0 == I[X] then
					I[X], w[X] = nil, nil;
				end;
			end;
		return (d(340847, {}))(a(p));
	end)(getfenv and getfenv() or _ENV, unpack or table[n(18448)], newproxy, setmetatable, getmetatable, select, { ... });
end)(...);
