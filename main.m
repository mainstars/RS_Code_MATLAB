clc;
clear;

% 生成所有可能的三位信源，每一位取值 0~7，共 8^3 = 512 种
[x1, x2, x3] = ndgrid(0:7, 0:7, 0:7);
all_msg = [x1(:), x2(:), x3(:)];

% 将所有信源映射到 GF(2^3) 域
all_msg_gf = gf(all_msg, 3);

% 对所有可能信源进行 RS 编码，得到所有正确码字
all_code_msg = rs_encode(all_msg_gf);

% 随机产生 5 组信号，每组 3 个码元，每个码元范围 0~7
msg = floor(rand(5, 3) * 8)

% 映射到 GF 域
MSG = gf(msg, 3);

% 对随机信号进行 RS 编码
code = rs_encode(MSG)

% 产生噪声：前 5 位不加噪声，后 2 位加入随机噪声
a = zeros(5, 5);
b = floor(rand(5, 2) * 8);
noise = [a, b];

NOISE = gf(noise, 3);

% 接收信号 = 正确编码 + 噪声
in_msg = code + NOISE

% 对接收到的 5 组信号进行译码
new_msg = zeros(5, 3);

for ii = 1:5
    new_msg(ii, :) = rs_decode(in_msg(ii, :), all_code_msg, all_msg);
end

% 输出译码结果
new_msg

% 计算译码正确个数
num_same = sum(sum(msg == new_msg));

% 计算译码正确率
num = num_same / 15