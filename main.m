%% RS(7,3) 编解码仿真主程序
% RS(7,3) over GF(2^3): n=7, k=3, d_min=5, 可纠正 t=2 个符号错误
% 使用穷举查找表进行最小距离译码

clc;
clear;

% ===== 仿真配置 =====
NUM_TEST_MSGS = 5;          % 随机测试消息数量
NOISE_SYMBOLS = 2;          % 每个码字中加入噪声的符号数（加在末尾）
MSG_SYMBOLS = 3;            % 消息长度 k=3
CODE_SYMBOLS = 7;           % 码字长度 n=7

%% 第 1 步：生成所有可能的正确码字（查找表）
% 三位信源，每一位取值 0~7，共 8^3 = 512 种可能
[x1, x2, x3] = ndgrid(0:7, 0:7, 0:7);
all_msg = [x1(:), x2(:), x3(:)];                    % 512×3 double

% 将所有信源映射到 GF(2^3) 域并编码，得到所有正确码字
all_msg_gf = gf(all_msg, 3);                        % 512×3 GF
all_code_msg = rs_encode(all_msg_gf);               % 512×7 GF

fprintf('查找表构建完成：共 %d 个正确码字\n', size(all_code_msg, 1));

%% 第 2 步：生成随机测试消息
msg = floor(rand(NUM_TEST_MSGS, MSG_SYMBOLS) * 8);  % 随机 5×3 消息
fprintf('\n========== 随机生成的消息 ==========\n');
for i = 1:NUM_TEST_MSGS
    fprintf('  消息 %d: [%d %d %d]\n', i, msg(i, :));
end

%% 第 3 步：对随机消息进行 RS 编码
MSG = gf(msg, 3);                                   % 映射到 GF(2^3)
code = rs_encode(MSG);                              % 编码为 5×7 码字

fprintf('\n========== 编码后的码字（消息 | 校验） ==========\n');
for i = 1:NUM_TEST_MSGS
    % 将 GF 元素转回整数 0~7 用于显示
    code_ints = gf2int_display(code(i, :));
    fprintf('  码字 %d: [%d %d %d | %d %d %d %d]\n', i, code_ints);
end

%% 第 4 步：添加噪声，模拟传输过程
% 噪声模型：前 (CODE_SYMBOLS - NOISE_SYMBOLS) = 5 列不加噪声，
%           后 NOISE_SYMBOLS = 2 列加入随机噪声 (0~7 的 GF 元素)
%
% RS(7,3) 可纠正最多 t=2 个符号错误，因此 2 个噪声符号是纠错边界情况。
% 只要噪声不把码字变成另一个有效码字，译码就能成功。

noise_zeros = zeros(NUM_TEST_MSGS, CODE_SYMBOLS - NOISE_SYMBOLS);  % 5×5
noise_random = floor(rand(NUM_TEST_MSGS, NOISE_SYMBOLS) * 8);      % 5×2
noise = [noise_zeros, noise_random];                                % 5×7

NOISE = gf(noise, 3);                               % 映射到 GF(2^3)

% 接收信号 = 编码码字 + 噪声（GF 域加法即为逐位异或）
in_msg = code + NOISE;                              % 5×7 GF

fprintf('\n========== 接收到的信号（含噪声，消息 | 校验） ==========\n');
for i = 1:NUM_TEST_MSGS
    in_msg_ints = gf2int_display(in_msg(i, :));
    fprintf('  接收 %d: [%d %d %d | %d %d %d %d]\n', i, in_msg_ints);
end

%% 第 5 步：对接收信号进行译码
new_msg = zeros(NUM_TEST_MSGS, MSG_SYMBOLS);

for ii = 1:NUM_TEST_MSGS
    new_msg(ii, :) = rs_decode(in_msg(ii, :), all_code_msg, all_msg);
end

%% 第 6 步：分析并展示译码结果
fprintf('\n========== 译码结果 ==========\n');
fprintf('%-8s %-20s %-20s %s\n', '', '原始消息', '译码结果', '状态');
fprintf('%-8s %-20s %-20s %s\n', '', '--------', '--------', '----');

correct_count = 0;
for i = 1:NUM_TEST_MSGS
    is_correct = isequal(msg(i, :), new_msg(i, :));
    if is_correct
        correct_count = correct_count + 1;
        status = '✓ 正确';
    else
        status = '✗ 错误';
    end
    fprintf('  消息 %d  [%d %d %d]           [%d %d %d]            %s\n', ...
        i, msg(i, :), new_msg(i, :), status);
end

% 计算译码正确率
num_total = NUM_TEST_MSGS * MSG_SYMBOLS;            % 总符号数 = 15
num_same = sum(sum(msg == new_msg));                 % 正确译码的符号数
correct_rate = num_same / num_total;                 % 符号正确率

fprintf('\n========== 统计结果 ==========\n');
fprintf('  消息级别正确率: %d / %d = %.1f%%\n', ...
    correct_count, NUM_TEST_MSGS, correct_count / NUM_TEST_MSGS * 100);
fprintf('  符号级别正确率: %d / %d = %.1f%%\n', ...
    num_same, num_total, correct_rate * 100);

% 理论说明
fprintf('\n理论说明:\n');
fprintf('  RS(7,3) 码 d_min=5，可纠正最多 t=2 个符号错误。\n');
fprintf('  本仿真在 %d 个码元中注入噪声，处于纠错能力边界。\n', NOISE_SYMBOLS);


% ===== 辅助函数 =====
function vals = gf2int_display(gf_row)
% 将 GF(2^3) 行向量转为整数 0~7，用于终端显示
% MATLAB 自 R2016b 起支持脚本末尾添加局部函数

    vals = zeros(1, length(gf_row));
    for j = 1:length(gf_row)
        for k = 0:7
            if gf_row(j) == gf(k, 3)
                vals(j) = k;
                break;
            end
        end
    end
end
