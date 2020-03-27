% Zahorack [xhollyo] 
% 23.3.2020

% import java.util.LinkedList

classdef FrameSequnceFilter < handle
    
    properties (Access = private)
        m_order;
        m_period;
        m_counter;
        m_mask;
        m_frameQueue = java.util.LinkedList();
    end
    
    %Functions
    methods (Access = public)
        
        function obj = FrameSequnceFilter(order, period)
            obj.m_order = order;
            obj.m_period = period;
            obj.m_counter = 0;
        end
        
        function mask = update(obj, frame)
            
            if(~mod(obj.m_counter, obj.m_period) || obj.m_counter == 0)
                obj.m_mask = frame;
                obj.m_frameQueue.add(frame);


                for fidx = 0 : obj.m_frameQueue.size()-1
                    obj.m_mask = obj.m_mask | obj.m_frameQueue.get(fidx);
                end

                if(obj.m_frameQueue.size() >= obj.m_order)
                    obj.m_frameQueue.remove();
                end
            end
            
            mask = obj.m_mask;
            obj.m_counter = obj.m_counter + 1;
        end
        
        
    end
    
end