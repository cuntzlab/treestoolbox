%% check_smoothbranch

%% test 1
clf; hold on;
N            = 20;
for ge       = 1 : 3
    for te   = 1 : 3
        X    = (0 : N)' + rand (N + 1, 1);
        Y    = randn (N + 1, 1) * 10;
        Y    = convn (Y, ones (5, 1) /5, 'same');
        Z    = randn (N + 1, 1) * 10;
        Z    = convn (Z, ones (5, 1) /5, 'same');
        for counter  = 1 : 10
            [Xs, Ys, Zs] = smoothbranch ( ...
                X, Y, Z, ...
                (counter - 1) / 10, counter);
            HP       = plot3 ( ...
                te * 25 + Xs, ...
                ge * 25 + Ys, ...
                Zs, 'k.-');
            set      (HP, ...
                'linewidth',   2, ...
                'color',       ([counter counter counter] - 1) / 10);
        end
    end
end
view         (2);
axis         off image
tprint       ('./panels/smoothbranch1', ...
    '-jpg -HR',                [10 10]);

%% test 3
smoothbranch (X, Y, Z, 0.5, 300000);



