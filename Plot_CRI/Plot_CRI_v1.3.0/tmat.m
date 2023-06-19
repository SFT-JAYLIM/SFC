function T = tmat(alpha, a, d, theta)
        % tmat(alpha, a, d, theta) (T-Matrix used in Robotics)
        % The homogeneous transformation called the "T-MATRIX"
        % as used in the Kinematic Equations for robotic type
        % systems (or equivalent).
        %
        % This is equation 3.6 in Craig's "Introduction to Robotics."
        % alpha, a, d, theta are the Denavit-Hartenberg parameters.
        % -> change Robotics Modelling planing and control eq 2.52 by seop
        %
        % (NOTE: ALL ANGLES MUST BE IN DEGREES.)
        %
%         alpha = alpha*pi/180;    %Note: alpha is in radians.
%         theta = theta*pi/180;    %Note: theta is in radians.
        c = cos(theta);
        s = sin(theta);
        ca = cos(alpha);
        sa = sin(alpha);
        T = [c -s*ca s*sa a*c; s c*ca -c*sa a*s; 0 sa ca d; 0 0 0 1];
    end