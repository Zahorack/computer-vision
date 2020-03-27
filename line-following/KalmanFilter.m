

classdef KalmanFilter < handle
    
    properties
        x_est_last = 0;
        P_last = 0;
        Q = 0.025;
        R = 0.7;
    end
    
    methods (Access = public)
        
        function obj = KalmanFilter(varargin)
            if nargin == 2
                obj.Q = varargin{1};
                obj.R = varargin{2};  
            end

        end
        
        function output = update(obj, input)
         
            x_temp_est = obj.x_est_last;
            P_temp = obj.P_last + obj.Q;
        
            K = P_temp * (1.0/(P_temp + obj.R));
        
            x_est = x_temp_est + K * (input - x_temp_est);
            P = (1- K) * P_temp;
        
            obj.P_last = P;
            obj.x_est_last = x_est;
            
            output = x_est;
        end
    end
end
