

classdef KalmanFilterForPoint < handle
    
    properties
        kalman1;
        kalman2;
    end
    
    methods  (Access = public)
        function obj = KalmanFilterForPoint(varargin)
            if nargin == 2
                obj.kalman1 = KalmanFilter(varargin{1}, varargin{2});
                obj.kalman2 = KalmanFilter(varargin{1}, varargin{2});
            end
        end
    
        function output = update(obj, input)

            v1 = obj.kalman1.update(input(1));
            v2 = obj.kalman2.update(input(2));

            output = [v1, v2];
        end
           
    end
    
    
end