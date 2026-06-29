function new_msg = rs_decode(in_msg, all_code_msg, all_msg)
% RS 译码函数
% 输入：
% in_msg        接收到的码字
% all_code_msg  所有可能信源对应的正确 RS 编码
% all_msg       所有可能的原始信源
% 输出：
% new_msg       译码后的信源

new_msg = rs_interpret(in_msg, all_code_msg, all_msg);

end


function interpret_msg = rs_interpret(in_msg, all_code_msg, all_msg)
% 找到与接收码字距离最近的正确码字

rs_dis = zeros(1, 512);

for i = 1:512
    rs_dis(i) = rscode_dis(in_msg, all_code_msg(i, :));
end

rs_dis_min = min(rs_dis);
index = find(rs_dis == rs_dis_min);

% 取距离最小的那个码字对应的原始信源
interpret_msg = all_msg(index(1), :);

end


function dis = rscode_dis(code1, code2)
% 计算两个 RS 码字之间的距离

dis = 0;

for i = 1:7
    temp = gf_dis(code1(i), code2(i));
    dis = dis + temp;
end

end


function ret = gf_dis(a, b)
% 计算 GF 域内两个码元的二进制码距

a_num = gf2num_local(a);
b_num = gf2num_local(b);

% 转为 3 位二进制
a_bits = bitget(a_num, 3:-1:1);
b_bits = bitget(b_num, 3:-1:1);

temp = mod(a_bits + b_bits, 2);
ret = sum(temp);

end


function distance = gf2num_local(gf_a)
% 将 GF(2^3) 域中的元素映射成普通数字 0~7

distance = -1;

for k = 0:7
    if gf_a == gf(k, 3)
        distance = k;
        return;
    end
end

end