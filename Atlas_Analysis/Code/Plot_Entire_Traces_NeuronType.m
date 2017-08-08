function Plot_Entire_Traces_NeuronType(nFile)
addpath('../Func');
setDir;

load([DirNames{nFile} '\data.mat'], 'dff');
% % option 1: use Ziqiang's definition of neuronType
% if ~exist([DirNames{nFile} '\LONOLoading_v_0_1.mat'], 'file')
%     return
% end
% load([DirNames{nFile} '\LONOLoading_v_0_1.mat'], 'neuronType');

% option 2: use factorSize to determine neuronType
% load([TempDataDir '/tmp_' dataset{nFile} '.mat'], 'factorSize');
% neuronType = nan(size(dff, 1), 1);
% neuronType(factorSize<=1) = 1;
% neuronType(factorSize<=2 & factorSize>1) = 2;
% neuronType(factorSize>2) = 3;

% option 3: use neuronActTime to determine neuronType
load(['../../NetworkDynamicsTempDat/NeuronActTime' dataset{nFile} '.mat'], 'neuronActTime');
neuronType = neuronActTime;
neuronType(neuronActTime >= 0.6) = 1;
neuronType(neuronActTime < 0.6) = 2;


spacing = 2;
timepoints = (1:size(dff, 2))/(4*3600);
for i = [0 unique(neuronType(~isnan(neuronType)))']
    if i==0
        cell_id = isnan(neuronType);
    else
        cell_id = neuronType==i;
    end
    figure('Position', [0, 100, 500, sum(cell_id)* 30]);
    plot(timepoints, dff(cell_id, :)+ repmat(-(0:(sum(cell_id)-1))'*spacing, 1, numel(timepoints)));
    text(zeros(sum(cell_id), 1), -(0:(sum(cell_id)-1))'*spacing, cellstr(num2str(find(cell_id))));
    text(zeros(sum(cell_id), 1)-0.5, -(0:(sum(cell_id)-1))'*spacing, cellstr(num2str(neuronActTime(cell_id), '%.2f')));
    xlim([0, max(timepoints)]);
    ylim([floor(-sum(cell_id)*spacing), spacing]);
    axis off
    colormap(lines)
    title(['neuron type = ' num2str(i)])
    box off;
    export_fig([PlotDir '/Entire_Traces_' dataset{nFile} 'NeuronActTime_type' num2str(i) '.pdf'], '-nocrop');
    close
end
