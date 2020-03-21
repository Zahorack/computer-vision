% xhollyo 
% 21.3.2020

classdef HsvFrame < handle
    %Data   
    properties (Constant)
        hueIndex = 1;
        saturationIndex = 2;
        valueIndex = 3;
    end
    
    properties (Access = private)
        m_frame;
    end
    
    %Functions     
    methods (Access = public)
        function obj = HsvFrame(varargin)
        
            if nargin == 1
                obj.m_frame = varargin{1};
            elseif nargin == 0
            end
            
        end
        
        
        function frame = get(obj)
            frame = obj.m_frame;
        end
        
        function show(obj)
            imshow(obj.m_frame);
        end
        
        function dimension = hue(obj, spectrum)
            if nargin == 1
                dimension = obj.m_frame(:,:,1);
            elseif nargin == 2
                obj.m_frame(:,:,1) = spectrum;
            end
        end
        
        function dimension = saturation(obj, spectrum)
           if nargin == 1
                dimension = obj.m_frame(:,:,2);
            elseif nargin == 2
                obj.m_frame(:,:,2) = spectrum;
            end
        end
        
        function dimension = value(obj, spectrum)
            if nargin == 1
                dimension = obj.m_frame(:,:,3);
            elseif nargin == 2
                obj.m_frame(:,:,3) = spectrum;
            end
        end
        
        function update(obj, frame)
           obj.m_frame = frame;
        end
        
        
    end
    
    
    methods (Static)
    
    end
    
end