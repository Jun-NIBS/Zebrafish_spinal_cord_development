%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Segment analysis
% 1: segment rank statistics
%
% all metrics prestored in "listLeaderMetrics"
% -------------------------------------------------------------------------
% Yinan Wan
% wany@janelia.hhmi.org
% 

addpath('../Func');
setDir;
fileList = [3,4,10,12,13,15,16,23];
% fileList = 6;

locationList = [];
orderList = [];
for nFile = fileList
    fileName          = fileNames{nFile};
    load([tempDatDir, 'Leader_', fileName, '.mat'], 'activeTime');
    load([tempDatDir, fileName, '.mat'], 'timePoints', 'new_x', 'new_y', 'mnx');
    actOrder = nan(numel(new_x), 1);
    
    x = new_x;
    y = new_y;
    metric = activeTime;
    for seg = floor(min(x-0.5)):ceil(max(x-0.5))
        currentSegLeft = find(y<0 & x>=seg+0.5 & x<seg+1.5 & mnx==1 & ~isnan(metric));
        [~, ~, ic] = unique(metric(currentSegLeft));
        actOrder(currentSegLeft) = ic;
        currentSegRight = find(y>0 & x>=seg+0.5 & x<seg+1.5 & mnx==1 & ~isnan(metric));
        [~, ~, ic] = unique(metric(currentSegRight));
        actOrder(currentSegRight) = ic;
    end
    locationList = [locationList; x(~isnan(actOrder))];
    orderList = [orderList; actOrder(~isnan(actOrder))];
end
locationList = locationList-0.5 - floor(locationList-0.5);
bins = 1:max(orderList)+1;
nbins = 20;
a_bins = linspace(0, 1-1/nbins, nbins);

count = polar_histogram(orderList, locationList, bins, a_bins);
figure, plot(a_bins(1:end-1), count');
legend(num2str(bins(1:end-1)'));
hold on
plot([0.5, 0.5], [0, 25], '--k');
hold off

hList = nan(max(orderList), 1);
pList = nan(max(orderList), 1);
for i = 1:max(orderList)
    currentLoc = locationList(orderList==i);
    [hList(i), pList(i)] = kstest(currentLoc, 'cdf', makedist('uniform'));
end