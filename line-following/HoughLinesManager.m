

classdef HoughLinesManager < handle
    
    properties
       lines; 
    end
    
    methods (Access = public)
       
        function obj = HoughLinesManager(varargin)
            
            if nargin == 1
                obj.lines = varargin{1};
            end
        end
        
        function set(obj, lin)
           obj.lines = lin; 
        end
        
        function [near_point, far_point] = statisticsPoints(obj)

            points = obj.mergePoints();

            zone = 10;

            max1 = max(points(:,1));
            max2 = max(points(:,2));
            maximum = max([max1; max2]);

            far_cnt = 1;
            near_cnt = 1;
            persistent old_near old_far;

            for idx = 1:length(points)
                if obj.inRange(points(idx,1), maximum - zone, maximum + zone)
                    near(near_cnt,:) = [points(idx,1), points(idx,2)];
                    near_cnt = near_cnt+1;
                elseif obj.inRange(points(idx,2), maximum - zone, maximum + zone)
                    near(near_cnt,:) = [points(idx,2), points(idx,1)];
                    near_cnt = near_cnt+1;

                elseif points(idx,2) > points(idx,1)
                    far(far_cnt,:) = [points(idx,2), points(idx,1)];
                    far_cnt = far_cnt+1;
                else
                    far(far_cnt,:) = [points(idx,1), points(idx,2)];
                    far_cnt = far_cnt+1;
                end
            end


            if(near_cnt > 1)
                med11 = mode(near(:,1));
                med12 = mode(near(:,2));
                if(med11 > med12)
                    near_point = [med11,  med12];
                else
                    near_point = [med12,  med11];
                end
            else
                near_point = old_near;
            end
            
            if far_cnt > 1
                med21 = mode(far(:,1));
                med22 = mode(far(:,2));

                if(med21 > med22)
                    far_point = [med21,  med22];
                else
                    far_point = [med22,  med21];
                end
            else
                 far_point =  old_far;
            end

            old_near = near_point;
            old_far = far_point;

        end
        
                
        function points = mergePoints(obj)
            points = zeros(length(obj.lines)*2,2);
            idn = 1;
            for idx = 1:length(obj.lines)
                points(idn,:) = obj.lines(idx).point1;
                points(idn+1,:) = obj.lines(idx).point2;
                idn = idn +2;
            end
        end
        
        function state = inRange(obj, value, min, max)
           if (value <= max && value >= min)
               state = 1;
           else 
               state = 0;
           end
        end
        
        
        function [points1, points2, thetas, rhos] = parse(obj)
            points1 = zeros(length(obj.lines),2);
            points2 = zeros(length(obj.lines),2);
            thetas = zeros(length(obj.lines)*2,1);
            rhos = zeros(length(obj.lines)*2,1);

            for idx = 1:length(obj.lines)
                points1(idx,:) = obj.lines(idx).point1;
                points2(idx,:) = obj.lines(idx).point2;
            end

            for idx = 1:length(obj.lines)
               thetas(idx) = obj.lines(idx).theta;
               rhos(idx) = obj.lines(idx).rho;
            end
        end

        function [point1, point2, theta, rho] = average(obj)

            [points1, points2, thetas, rhos] = parse(obj.lines);

            med11 = median(points1(:,1));
            med12 = median(points1(:,2));
            med21 = median(points2(:,1));
            med22 = median(points2(:,2));

            if(med11 > med12)
                point1 = [med11  med12];
            else
                point1 = [med12  med11];
            end

            if(med21 > med22)
                point2 = [med21  med22];
            else
                point2 = [med22  med21];
            end


            theta = mean(thetas);
            rho = mean(rhos);
        end

        function [p1, p2] = resizeLineOnScreen(obj, screen, point1, point2)
            
            p1 = point1;
            p2 = point2;
            
        end

    end
end