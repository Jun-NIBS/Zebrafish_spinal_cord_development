%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LMatCorrection_v_0_1
% PreLMatTracker_v_0_1
% Spectrogram_v0_3
% Spectrogram_v0_4
%
% Following NeuralActivityFactorTime_v0_5 with labeled neuron
% 1. local community pacemaker
% 2. local community non-active neuron
% 3. recruiting cells
%
% -------------------------------------------------------------------------
% 
% Ziqiang Wei
% weiz@janelia.hhmi.org
%
%


addpath('../Func');
setDir;  

corrMatMat = [];
cell_typeMat = [];

for nFile = [3 7 10 11 16]
    fileName   = fileNames{nFile};   %#ok<*USENS>
    load([tempDatDir, fileName, '.mat'], 'dff', 'timePoints', 'new_x', 'new_y', 'new_z')
    load([tempDatNetDir, 'LONOLoading_' fileName, '_v_0_3.mat'], 'LocalNeuronInd', 'neuronFactorInd', 'neuronFactorTime', 'LMats', 'neuronActLevel')
    
    numNeuron         = size(dff, 1);
    numTime           = length(timePoints);
    timeWin           = 30;  
    corrMat           = nan(numNeuron, 2);
    
    for nNeuron       = 1:numNeuron
        if ~isnan(neuronFactorTime(nNeuron)) && neuronFactorTime(nNeuron) > 5 && neuronFactorTime(nNeuron) < numTime - timeWin 
            nFactorTime  = neuronFactorTime(nNeuron);
            timeRangeMin = max([nFactorTime - 5 * floor((nFactorTime-1)/5),  nFactorTime - timeWin]);
            timeRangeMax = nFactorTime + min(timeWin*2, floor((numTime - nFactorTime)/5)*5);
            dffNeuron    = dff(nNeuron, timePoints(timeRangeMin)+1:timePoints(timeRangeMax));
            load([tempDatNetDir, 'LONOLoading_' fileName, '_v_0_1.mat'], 'new_activeNeuronMat')
            dffNeuron    = ca2spike(dffNeuron, new_activeNeuronMat(nNeuron, timeRangeMin:timeRangeMax));
            dffNeuron    = reshape(dffNeuron, 1200, []);
            timeInd      = ((timeRangeMin+5):5:timeRangeMax) - nFactorTime;
            nTimeMat     = nan(length(timeInd));
            for nTime    = 1:length(timeInd)-1
                for mTime= nTime+1:length(timeInd)
                    nTimeMat(nTime, mTime) = nanmax(abs(xcorr(dffNeuron(:, nTime)', dffNeuron(:, mTime)', 'coeff')));
                end
            end
%             figure;
%             imagesc(timeInd, timeInd, nTimeMat)
%             [v_min, v_max] = caxis();
%             caxis([0, v_max])
%             gridxy(0, 0, 'color', 'w', 'linestyle', '--')
%             xlabel('Time (min)')
%             ylabel('Time (min)')
%             set(gca, 'TickDir', 'out')
%             setPrint(8, 6, 'Neuron_57', 'pdf')
            corrMat(nNeuron, 1) = nanmax(nanmax(nTimeMat(timeInd<0, timeInd<15 & timeInd>0)));
            if isnan(corrMat(nNeuron, 1)); corrMat(nNeuron, 1) = 0; end
            corrMat(nNeuron, 2) = nanmax(nanmax(nTimeMat(timeInd<15 & timeInd>0, timeInd>15 & timeInd<30)));
            if isnan(corrMat(nNeuron, 2)); corrMat(nNeuron, 2) = 0; end
        end
    end    
    
    cell_type = double(LocalNeuronInd);
    cell_type(LocalNeuronInd & neuronActLevel < 0.5) = 2;
%     figure;
%     scatter(corrMat(:, 1), corrMat(:, 2), [], cell_type, 'filled')
%     refline(1)

    corrMatMat = [corrMatMat; corrMat];
    cell_typeMat = [cell_typeMat; cell_type];
    
end

figure;
scatter(corrMatMat(:, 1), corrMatMat(:, 2), [], cell_typeMat, 'filled')
refline(1)

xlabel('Peak correlation before merge')
ylabel('Peak correlation after merge')
setPrint(8, 6, 'Neuron_57', 'pdf')