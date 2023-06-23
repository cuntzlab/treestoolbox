% LIF leaky integrate-and-fire
% (sweeps package)
%
% [v, t, sp]  = LIF (cc, g, E, dt, tau, rin, vrest, thr, vreset, Aspike)
% ----------------------------------------------------------------
%
% The leaky integrate-and-fire neuron integrates the current inputs in cc
% onto the membrane potential with respect to the input resistance rin. The
% membrane time constant tau determines how slowly the membrane potential
% responds to these inputs and how slowly it is pulled back to the resting
% potential vrest. If the membrane voltage exceeds the spiking threshold
% thr a spike of amplitude Aspike is elicited and 
%
% Input
% -----
% - cc       ::vector:   current input in [nA]
% - dt       ::number:   time bin in [ms]
% - tau      ::number:   time constant of the membrane in [ms]
% - rin      ::number:   input resistance in [MOhm]
% - vrest    ::number:   resting potential of the membrane in [mV]
% - thr      ::number:   spiking threshold compared to vrest in [mV]
% - vreset   ::number:   reset potential after spike compared to vrest in [mV]
% - Aspike   ::number:   amplitude of spike compared to vrest in [mV]
%
% Output
% ------
% - v        ::vector:   membrane voltage in [mV] for each time bin (same
%     size as cc)
% - t        ::vector:   time value in [ms] for each time bin
% - sp       ::vector:   spike times in [ms] for each spike
%
% Example
% -------
% cc           = rand (500, 1) * 0.2;
% [v, t]       = LIF (cc);
% plot         (t, v);
%
%
% the SWEEPS toolbox
% Copyright (C) 2009 - 2015  Hermann Cuntz

function [v, t, sp]  = LIF (cc, g, E, dt, tau, rin, vrest, thr, vreset, Aspike)

if (nargin < 2) || isempty (g)
    % {DEFAULT: no input}
    g       = cc * 0;
end

if (nargin < 3) || isempty (E)
    % {DEFAULT: [0 -80]}
    E       = [65 -20];
end

if (nargin < 4) || isempty (dt)
    % {DEFAULT: 1 ms}
    dt       = 1;
end
if (nargin < 5) || isempty (tau)
    % {DEFAULT: 10 ms}
    tau      = 10;
end
if (nargin < 6) || isempty (rin)
    % {DEFAULT: 10 MOhm}
    rin       = 10;
end
if (nargin < 7) || isempty (vrest)
    % {DEFAULT: -65 mV}
    vrest    = -65;
end
if (nargin < 8) || isempty (thr)
    % {DEFAULT: 10 mV compared to rest}
    thr       = 10;
end
if (nargin < 9) || isempty (vreset)
    % {DEFAULT: 0 mV compared to rest}
    vreset   = 0;
end
if (nargin < 10) || isempty (Aspike)
    % {DEFAULT: 75 mV compared to rest}
    Aspike   = 75;
end

tstop        =   (length (cc) - 1) * dt;
t            =        (0 : dt : tstop)';
v            =    zeros (length (t), 1);
v (1)        =                        0;
sp           =                       [];
gin          =                  1 / rin;
for counterT = 2 : length (t)
    % current injection:
    rinS     = 1 / (gin + sum (g (counterT, :), 2));
    v (counterT)         = ...
        (tau * v (counterT - 1) / dt) + ...
        (rinS * cc (counterT));
    % the following disregards g effect on rin
    for counterg = 1 : size (g, 2)
        v (counterT)     = v (counterT) - ...
            (rinS * (g (counterT, counterg) * (v (counterT - 1) - E (counterg))));
    end
    v (counterT)         = v (counterT) ./ (1 + tau / dt);  
    if  v (counterT)     >=  thr       % voltage reaches threshold -> reset
        v (counterT - 1) =   Aspike;   % spike amplitude
        v (counterT)     =   vreset;   % reset voltage
        sp               =   [sp; (counterT * dt)]; % remember spike times
    end
end
v                        = v + vrest;



