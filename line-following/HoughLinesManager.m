

classdef HoughLinesManager < handle
    
    properties (Constant)
        KalmanFilterQ = 0.025;
        KalmanFilterR = 0.2; 
    end
    
    properties
        last_lines;
        lines;
        kalmanPoint1;
        kalmanPoint2;
    end
    
    methods (Access = public)
       
        function obj = HoughLinesManager(varargin)
            
            if nargin == 1
                obj.lines = varargin{1};
                obj.last_lines = obj.lines;
            end
            
            obj.kalmanPoint1 =  KalmanFilterForPoint(obj.KalmanFilterQ, obj.KalmanFilterR);
            obj.kalmanPoint2 =  KalmanFilterForPoint(obj.KalmanFilterQ, obj.KalmanFilterR);
        end
        
        function set(obj, lin)
           obj.lines = lin; 
           
           if isempty(obj.lines)
              obj.lines = obj.last_lines;
           end
           
           obj.last_lines = obj.lines;
        end
                
        function lastSet(obj)
              obj.lines = obj.last_lines;
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

            [points1, points2, thetas, rhos] = obj.parse();
            
            med11 = median(points1(:,1));
            med12 = median(points1(:,2));
            med21 = median(points2(:,1));
            med22 = median(points2(:,2));

            point1 = [med11  med12];
            point2 = [med21  med22];

            theta = mean(thetas);
            rho = mean(rhos);
        end

       
        
        function [p1, p2] = pointsAverageByModule(obj, percentage)
            
            points = obj.mergePoints();
            
            persistent  old_search1 old_search2;
            
            if isempty(points)
                modules(1) = 0;
            else
                for idx = 1:length(points)
                   modules(idx) =  obj.moduleOfPoint(points(idx,:));
                end
            end
            
   
            modMin = min(modules);
            modMax = max(modules);
           
            
            id1 = 0;
            id2 = 0;
            for idx = 1:length(points)
                
                mod = modules(idx);
                interval = (mod/100)*percentage;
                
                if obj.inRange(mod, modMax -interval, modMax +interval)
                    id1 = id1 + 1;
                    search1(id1,:) = points(idx, :); 
                    
                elseif obj.inRange(mod, modMin -interval, modMin +interval)
                    id2 = id2 + 1;
                    search2(id2,:) = points(idx, :); 
                end                
            end
                        
            if(id1 > 0)
                p1 = [mean(search1(:,1)), mean(search1(:,2))];
                old_search1 = p1;
            else
                p1 = old_search1;
            end
            
            
            if(id2 > 0)
                p2 = [mean(search2(:,1)), mean(search2(:,2))];
                old_search2 = p2;
            else
                p2 = old_search2;
            end
            
            p1 = obj.kalmanPoint1.update(p1);
            p2 = obj.kalmanPoint2.update(p2);
            
        end
        
        function modul = moduleOfPoint(obj, point)
           modul = sqrt(point(1)^2 + point(2)^2);
        end
            
        function [p1, p2] = resizeLineOnScreen(obj, screen, point1, point2)
            
            [ySize,xSize,cSize] = size(screen);
            
            [k, q] = obj.getStraightLineEquation(point1, point2);
            
            p1 = [(0 - q)/k, 0];
            p2 = [(ySize - q)/k, ySize];
            
        end
        
        function [k, q] = getStraightLineEquation(obj, p1, p2)
            
            A = [p1(1) 1; p2(1) 1];
            B = [p1(2); p2(2)];
            
            C = A\B;
            
            k = C(1);
            q = C(2);
        end

    end
end