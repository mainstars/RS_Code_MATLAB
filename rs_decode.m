function new_msg = rs_decode(in_msg, all_code_msg, all_msg)
% RS 译码函数 — 查找表最小距离译码
%
% 算法：穷举比较接收码字与所有 512 个正确码字的符号级汉明距离，
%       选择距离最小的那个码字对应的原始信源作为译码输出。
%
% RS(7,3) 码参数：
%   n = 7 (码字长度), k = 3 (消息长度)
%   d_min = n - k + 1 = 5 (最小符号距离)
%   可纠正 t = floor((d_min-1)/2) = 2 个符号错误
%
% 输入：
%   in_msg        - 接收到的码字 (1×7 GF(2^3) 数组)
%   all_code_msg  - 所有 512 个可能信源对应的正确 RS 编码 (512×7 GF(2^3) 数组)
%   all_msg       - 所有 512 个可能的原始信源 (512×3 double 数组)
%                   注意：all_msg 与 all_code_msg 的行顺序必须一致
%
% 输出：
%   new_msg       - 译码后的信源 (1×3 double 数组)
%
% 参考：main.m 中预计算了 all_code_msg 和 all_msg 查找表

    new_msg = rs_interpret(in_msg, all_code_msg, all_msg);

end


function interpret_msg = rs_interpret(in_msg, all_code_msg, all_msg)
% 查找到与接收码字符号级汉明距离最近的正确码字
% 若存在多个距离最近的码字（超过纠错能力时），取第一个

    num_codewords = size(all_code_msg, 1);     % 512 个候选码字
    distances = zeros(1, num_codewords);       % 预分配距离数组

    for i = 1:num_codewords
        distances(i) = rscode_dis(in_msg, all_code_msg(i, :));
    end

    [min_dist, min_idx] = min(distances);

    % 取距离最小的码字对应的原始信源（多个最小值时取第一个）
    interpret_msg = all_msg(min_idx(1), :);

end


function dis = rscode_dis(code1, code2)
% 计算两个 RS 码字之间的符号级汉明距离
%
% 对于 RS(7,3)，每个码字有 7 个 GF(2^3) 符号。
% 距离 = 两个码字在对应位置上符号不同的位置个数。
%
% 这符合 RS 码的标准定义：d_min = 5 意味着任意两个
% 不同码字至少有 5 个符号位置的值不同。

    dis = 0;
    for i = 1:length(code1)
        if code1(i) ~= code2(i)
            dis = dis + 1;
        end
    end

end
