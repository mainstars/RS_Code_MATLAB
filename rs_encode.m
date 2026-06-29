function code = rs_encode(msg)
% RS 编码函数
% 输入：msg，GF(2^3) 域中的信息码
% 输出：code，编码后的 RS(7,3) 码字

g = [
    1 0 0 3 2 1 3
    0 1 0 5 5 1 4
    0 0 1 7 6 1 6
];

% 将生成矩阵映射到 GF(2^3) 域
g = gf(g, 3);

% 编码：信息码乘生成矩阵
code = msg * g;

end