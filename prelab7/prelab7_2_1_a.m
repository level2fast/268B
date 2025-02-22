%% 1.a Using the 32 subcarrier data from the previous simulation problem in Prelab 6, simulate
% the channel given by the discrete impulse response h[n] = δ[n] − δ[n − 16].
% Summary: Delay spread refers to the spreading of a transmitted signal over 
% time due to multipath propagation in the channel. As a result, different 
% copies of the transmitted signal arrive at the receiver with different 
% delays, causing distortion of the received signal. The delay spread can 
% be characterized by the spread of the impulse response of the channel.
%
% Negative effects in OFDM:
% Delay spread can cause intersymbol interference (ISI) and degrade 
% system performance.
%
% How to model:
% One common model used to describe delay spread in OFDM systems is the 
% tapped delay line model. In this model, the channel impulse response is 
% represented as a sum of delayed and attenuated copies of the transmitted 
% signal, referred to as taps. Each tap corresponds to a distinct path in
% the multipath channel.
clear
clf
% Simulate the channel given by the discrete impulse response h[n] = δ[n] − δ[n − 16].
% create the received signal
num_symbols_qpsk    = 128;                    % Number of QPSK symbols
num_bits_per_symbol = 2;
total_qpsk_symbols  = num_bits_per_symbol*num_symbols_qpsk;
num_subcarriers     = 32;
num_samp_per_symbol = 32;
num_samples = total_qpsk_symbols * num_samp_per_symbol;

% generate random binary data for QPSK modulation
data = randi([0 3],[total_qpsk_symbols * num_subcarriers 1] );

% map binary data to QPSK symbols;
qpsk_symbols = exp(1j*data*pi/2);
sub_carrier = qpsk_symbols;

% convert symbols from serial to parallel
sig_parallel = ofdm_parallelizer(symbol_values=sub_carrier);

% perform ifft to on parallelized data 
temp_normalized  = ifft(sig_parallel,num_subcarriers) * sqrt(num_subcarriers);

% convert symbols from parallel to serial
sig_serial = ofdm_serializer(symbol_subcarrier_mat=temp_normalized);

% create transmit signal
sig_tx = sig_serial;

% need to create a delayed version of the received signal. This simulates the
% effect that the channel impulse response has on the transmitted OFDM signal.
% 
% convolution can be used to create a delayed and shifted version of a
% signal. Convolve the transmitted signal with a discrete time impulse
% response.

% create the channel impulse response
channel_imp_rsp = create_ch_imp_rsp(taps=32,time_delay=16);

% convolve transmit signal with channel impulse response
sig_rx = conv(sig_tx,channel_imp_rsp);

%% Repeat part prelab7.2.a
figure(1)
shifted_sig = sig_rx(1:length(sig_tx));
subcarrier_all = shifted_sig + sig_tx;
NFFT            = 2^nextpow2(length(subcarrier_all)); % Next power of 2 from length of signal
signal1_1       = subcarrier_all;
ofdm_fft1_1     = fft(signal1_1,NFFT);
fshift1_1       = (-NFFT/2:NFFT/2-1);
ofdm_psd1_1     = abs(ofdm_fft1_1).^2; 
plot(fshift1_1, fftshift(pow2db(ofdm_psd1_1)));
title('2.1.a.i OFDM RX Signal w/ Channel Impulse Response - PSD');
xlabel('Frequency (Hz)');
ylabel('Power(dB)');
grid on;

%% Plot the constellation of several subcarriers 
figure(6)
shifted_sig = sig_rx(1:length(sig_tx));
shifted_sig = reshape(shifted_sig, num_subcarriers, []);

recv_offset_sig = fft(shifted_sig);
subplot(3,1,1)
scatter(real(recv_offset_sig(1,:)),imag(recv_offset_sig(1,:)))
title("Constellation of the Lowest Frequency Subcarrier w/ a 2 ..." + ...
    "Sample Offset");
ylabel("Imaginary")
xlabel("Real")

subplot(3,1,2)
scatter(real(recv_offset_sig(num_subcarriers/4,:)), imag(recv_offset_sig(num_subcarriers/4,:)))
title("Constellation of the Middle Subcarrier w/ a 2 sample offset");
ylabel("Imaginary")
xlabel("Real")

subplot(3,1,3)
scatter(real(recv_offset_sig(num_subcarriers/2,:)), imag(recv_offset_sig(num_subcarriers/2,:))         )
title("Constellation of the Highest Frequency Subcarrier w/ a 2 ..." + ...
    "sample offset");
ylabel("Imaginary")
xlabel("Real")

