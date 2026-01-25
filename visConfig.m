function flag = visConfig(newValue)
    persistent visualization
    if nargin > 0
        visualization = newValue;
    end
    if isempty(visualization)
        visualization = false;
    end
    flag = visualization;
end
