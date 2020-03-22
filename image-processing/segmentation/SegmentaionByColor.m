% Zhorack [xhollyo]
% 22.3.2020

classdef SegmentaionByColor < handle
    
    properties
        m_tresholds = HsvTresholds; 
    end
    
    methods (Access = public)

        function obj = SegmentaionByColor(tresholds)
            obj.m_tresholds = tresholds;
        end
        
        function mask = binMask(~, frame, low, high)
            mask = frame > low & frame < high;
        end    
        
        %@binary segmentation by color
        %   input:  HSV image - frame
        %   output: binary array found pixels - mask
        function mask = binary(obj, frame)
            hsvframe = HsvFrame;
            hsvframe.update(frame);

            hsvmask = HsvFrame;
            
            hsvmask.hue(obj.binMask(hsvframe.hue(), obj.m_tresholds.HueLow,...
             obj.m_tresholds.HueHigh));
         
            hsvmask.saturation(obj.binMask(hsvframe.saturation(),...
            obj.m_tresholds.SaturationLow, obj.m_tresholds.SaturationHigh));
        
            hsvmask.value(obj.binMask(hsvframe.value(), obj.m_tresholds.ValueLow,...
             obj.m_tresholds.ValueHigh));

            mask = (hsvmask.hue() & hsvmask.saturation()  & hsvmask.value());
        end
           
          
    end
    
end