% v5 created after pilot v2.4, 12/7/16
% Preallocate EVERYTHING rather than sampling, since no. cells in bin are
%   leading too variation in JS
clear all; close all hidden; clc 
fmat=@(A,x)A(x); 

%% Learning session settings  
% One source must follow you around more than the other, both sources must
% be equal in accuracy. These details should be correct - the numbers (in
% the plots) do match up with the analytical quants

% Simulation setup
req.n_expts=20;     
req.n_subs=30;    
 
% Vary for the simulation (i.e. to check tt ok for overall design) 
log.sub_pyes=0.8; 

for o1=1:1 % Settings for acq code 
    log.n_persrc= 40; % N reps per source 
    log.n_catch = 0; 
    log.n_trials= log.n_persrc*4+ log.n_catch; 
   
    % Design settings 
    log.sub_pCorrect=0.50; % Subject accuracy  
%     log.src_pCorrect=[0.6 0.9]; 
    log.src_pCorrect=[0.55 0.95]; 
%     log.src_pCorrect=[0.5 1]; 
    
    
    log.pCorrect{1}=log.src_pCorrect; 
    log.pCorrect{2}=fliplr(log.src_pCorrect);
    log.pCorrect{3}= repmat(mean(log.src_pCorrect),1,2); 
    log.pCorrect{4}=[0.5 0.5];  
    
    % Columns
    col.truth=1;
    col.stim1=2; 
    col.stim2=3; 
    col.source=4;
    col.choice=5;
    col.rt=6; 
    col.info=7; 
    col.srcacc=8;
    col.outcome=9;
    col.trialnum=10;  
    col.srcagree=11;   
    % 
    col.pCorr_ifSubCorr=12; 
    col.pCorr_ifSubWrong=13; 
    
    %
    fmat=@(A,x)A(x); fvect= @(mat)mat(:);
end
for o=1:1 % Compile trialstats 
    data=[]; 
    for c=1:4
        d=nan(log.n_persrc, 10); 
        d(:,col.source)=c; 
        d(:,col.outcome)=(linspace(0,1,log.n_persrc)<log.sub_pCorrect)'; 
        if round(log.n_persrc*log.sub_pCorrect)~=log.n_persrc*log.sub_pCorrect, error('N per src x sub acc needs to be a round number!'); end 
        d(d(:,col.outcome)==1,col.srcacc)=(linspace(0,1,log.n_persrc*log.sub_pCorrect)<log.pCorrect{c}(2))'; 
        d(d(:,col.outcome)==0,col.srcacc)=(linspace(0,1,log.n_persrc*log.sub_pCorrect)<log.pCorrect{c}(1))';   
        
        
        
        
        d(:,col.pCorr_ifSubCorr)= log.pCorrect{c}(2); 
        d(:,col.pCorr_ifSubWrong)= log.pCorrect{c}(1); 
        
        data=[data; d]; 
    end  
    
    data(:, col.trialnum)= rand(log.n_trials,1); data=sortrows(data, col.trialnum);
    data(:, col.trialnum)=1:log.n_trials;
    
    % Hard design checks   
    if length(unique([mean(data(data(:, col.source)==1, col.srcacc)); mean(data(data(:, col.source)==2, col.srcacc)); mean(data(data(:, col.source)==3, col.srcacc))]))~=1, error('Acc not == for C/D/N!'); end  % Overall source accuracy 
    if (mean(data(data(:, col.source)==1, col.srcagree)) - mean(data(data(:, col.source)==3, col.srcagree)))-(mean(data(data(:, col.source)==3, col.srcagree)) - mean(data(data(:, col.source)==2, col.srcagree))) > 0.000001, error('Agreement difference C>N ~= for N>D !'); end
end   
for t=1:log.n_trials  
    
    % Choice simulator 
    data(t, col.choice)=rand<log.sub_pyes; 
    
%     
%     data(t, col.choice)=0; 
%     data(t, col.outcome)=1; 
%     data(t, col.source)=1; 
    
    
    
    
    % Knock on trial stats 
    wt.info_AgrDisagr= [data(t, col.choice) 1-data(t, col.choice)]; % What to say if source Agrees/Disagrees
    data(t, col.truth)= fmat( wt.info_AgrDisagr, data(t, col.outcome)+1); 
    wt.info_TrueFalse= [data(t, col.truth) 1-data(t, col.truth)];  
    data(t, col.info)= fmat( wt.info_TrueFalse, data(t, col.srcacc)+1); 
     data(t, col.srcagree) = data(t, col.info)== data(t, col.choice); 
     
     
     % Is AgrDisagr== TrueFalse? Check redundancy later
     
     wt=[]; 
end 

%% Plot  

% Compile to plottable 
pcol.dummy=1; 
pcol.sub_acc=structmax(pcol)+1;
pcol.sub_pyes=structmax(pcol)+1;
pcol.src_pAcc =structmax(pcol)+1:structmax(pcol)+4;
pcol.src_pAgr =structmax(pcol)+1:structmax(pcol)+4;
pcol.pAgr_subright =structmax(pcol)+1:structmax(pcol)+4;
pcol.pAgr_subwrong =structmax(pcol)+1:structmax(pcol)+4;
pcol.pAcc_subright =structmax(pcol)+1:structmax(pcol)+4;
pcol.pAcc_subwrong =structmax(pcol)+1:structmax(pcol)+4;
%
pcol.pDisagr_subright =structmax(pcol)+1:structmax(pcol)+4;
pcol.pDisagr_subwrong =structmax(pcol)+1:structmax(pcol)+4;
pcol.pInacc_subright =structmax(pcol)+1:structmax(pcol)+4;
pcol.pInacc_subwrong =structmax(pcol)+1:structmax(pcol)+4;
d_sum=nan(1, structmax(pcol)); s=1;
for c=1:4
    dd{c}=data(data(:, col.source)==c,:);
    
    % P trials
    d_sum(s, pcol.sub_acc)= mean(dd{c}(:, col.outcome));
    d_sum(s, pcol.sub_pyes)= mean(dd{c}(:, col.choice));
    d_sum(s, pcol.src_pAcc(c))= mean(dd{c}(:, col.srcacc));
    d_sum(s, pcol.src_pAgr(c))= mean(dd{c}(:, col.srcagree));
    d_sum(s, pcol.pAgr_subright(c))= mean(dd{c}(dd{c}(:, col.outcome)==1, col.srcagree));
    d_sum(s, pcol.pAgr_subwrong(c))= mean(dd{c}(dd{c}(:, col.outcome)==0, col.srcagree));
    d_sum(s, pcol.pDisagr_subright(c))= mean(dd{c}(dd{c}(:, col.outcome)==1, col.srcagree)==0);
    d_sum(s, pcol.pDisagr_subwrong(c))= mean(dd{c}(dd{c}(:, col.outcome)==0, col.srcagree)==0);
    d_sum(s, pcol.pAcc_subright(c))= mean(dd{c}(dd{c}(:, col.outcome)==1, col.srcacc));
    d_sum(s, pcol.pAcc_subwrong(c))= mean(dd{c}(dd{c}(:, col.outcome)==0, col.srcacc));
    d_sum(s, pcol.pInacc_subright(c))= mean(dd{c}(dd{c}(:, col.outcome)==1, col.srcacc)==0);
    d_sum(s, pcol.pInacc_subwrong(c))= mean(dd{c}(dd{c}(:, col.outcome)==0, col.srcacc)==0);
    
    
    %         % N trials
    %         d_sum(s, pcol.sub_acc)= sum(dd{c}(:, col.outcome)==1);
    %         d_sum(s, pcol.sub_pyes)= sum(dd{c}(:, col.choice)==1);
    %         d_sum(s, pcol.src_pAcc(c))= sum(dd{c}(:, col.srcacc)==1);
    %         d_sum(s, pcol.src_pAgr(c))= sum(dd{c}(:, col.srcagree)==1);
    %         d_sum(s, pcol.pAgr_subright(c))= sum(dd{c}(dd{c}(:, col.outcome)==1, col.srcagree)==1);
    %         d_sum(s, pcol.pAgr_subwrong(c))= sum(dd{c}(dd{c}(:, col.outcome)==0, col.srcagree)==1);
    %         d_sum(s, pcol.pDisagr_subright(c))= sum(dd{c}(dd{c}(:, col.outcome)==1, col.srcagree)==0);
    %         d_sum(s, pcol.pDisagr_subwrong(c))= sum(dd{c}(dd{c}(:, col.outcome)==0, col.srcagree)==0);
    %         d_sum(s, pcol.pAcc_subright(c))= sum(dd{c}(dd{c}(:, col.outcome)==1, col.srcacc)==1);
    %         d_sum(s, pcol.pAcc_subwrong(c))= sum(dd{c}(dd{c}(:, col.outcome)==0, col.srcacc)==1);
    %         d_sum(s, pcol.pInacc_subright(c))= sum(dd{c}(dd{c}(:, col.outcome)==1, col.srcacc)==0);
    %         d_sum(s, pcol.pInacc_subwrong(c))= sum(dd{c}(dd{c}(:, col.outcome)==0, col.srcacc)==0);
    
end

close all
for o=1:1 % Plotting 
    f.plotcols= 2;  f.plotrows=6;  f.figwidth= 1000; f.figheight=800; f.fontsize=13; f.fontsize_title=20;f.fontname='PT Sans Caption';
    f.subplot_VerHorz=[0.08 0.1]; f.fig_BotTop=[0.05 0.1]; f.fig_LeftRight=[0.1 0.05]; f.guidecolor=[0.1 0.1 0.1];
    figure('Name',  'Simulation stats', 'Position', [100 150 f.figwidth f.figheight], 'Color', 'w'); k=1;
    
    % Subject Accuracy
    wf.d=  d_sum(:, pcol.sub_acc); wf.null=0.5;
    subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
    % barwitherr( std(wf.d)/sqrt(req.n_subs), mean(wf.d), 'facecolor',[0 0.8 0])
    bar(wf.d, 'facecolor',[0 0.8 0])
    hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
    title('Overall Subject Accuracy','FontSize',f.fontsize_title), ylabel('% Accurate','FontSize',f.fontsize)
    set(gca,'FontSize',f.fontsize); xlim([0.5 1.5]); ylim([0 1])
    
    
    % Subject pYes
    wf.d=  d_sum(:, pcol.sub_pyes); wf.null=0.5;
    subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
    % barwitherr( std(wf.d)/sqrt(req.n_subs), mean(wf.d), 'facecolor',[0 0.8 0])
    bar(wf.d, 'facecolor',[0 0.8 0])
    hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
    title('Overall Subject Response Bias','FontSize',f.fontsize_title), ylabel('% Yes','FontSize',f.fontsize)
    set(gca,'FontSize',f.fontsize); xlim([0.5 1.5]);
    
    % New row
    k=(ceil((k-1)/f.plotcols)*f.plotcols )+1;
    
    % ------------------------------------------------------------------------------------------------------------------------
    
    % Source Accuracy
    wf.d=  d_sum(:, pcol.src_pAcc); wf.null=0.5;
    subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
%     barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
    bar(wf.d, 'facecolor','y')
    hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
    title('Overall source accuracy','FontSize',f.fontsize_title), ylabel('% Accurate','FontSize',f.fontsize)
    % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
    wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d ), 'UniformOutput',0);
    set(gca,'ytick', 0:0.25:1,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]);
    
    % Source Agreement
    wf.d=  d_sum(:, pcol.src_pAgr); wf.null=0.5;
    subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
    % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
    bar(wf.d, 'facecolor','y')
    hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
    title('Overall source agreement','FontSize',f.fontsize_title), ylabel('p(Agree)','FontSize',f.fontsize)
    % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
    wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d ), 'UniformOutput',0);
    set(gca,'ytick', 0:0.25:1,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 1])
    
    % ------------------------------------------------------------------------------------------------------------------------
    
    % Source Agreement when sub Correct
    wf.d=  d_sum(:, pcol.pAgr_subright); wf.null=0.5;
    subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
    % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
    bar(wf.d, 'facecolor',[0.8 0.8 1])
    hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
    title('p(Agree|Subject Correct)','FontSize',f.fontsize_title), ylabel('proportion','FontSize',f.fontsize)
    % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
    wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell(wf.d), 'UniformOutput',0);
    set(gca,'ytick', 0:0.25:1,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 1])
    
    % Source Agreement when sub Wrong
    wf.d=  d_sum(:, pcol.pAgr_subwrong); wf.null=0.5;
    subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
    % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
    bar(wf.d, 'facecolor',[0.8 0.8 1])
    hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
    title('p(Agree|Subject Wrong)','FontSize',f.fontsize_title), ylabel('proportion','FontSize',f.fontsize)
    % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
    wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d ), 'UniformOutput',0);
    set(gca,'ytick', 0:0.25:1,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 1])
    
    % Source DISAgreement when sub Correct
    wf.d=  d_sum(:, pcol.pDisagr_subright); wf.null=0.5;
    subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
    % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
    bar(wf.d, 'facecolor',[0.8 0.8 1])
    hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
    title('p(Disagree|Subject Correct)','FontSize',f.fontsize_title), ylabel('proportion','FontSize',f.fontsize)
    % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
    wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell(wf.d), 'UniformOutput',0);
    set(gca,'ytick', 0:0.25:1,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 1])
    
    % Source DISAgreement when sub Wrong
    wf.d=  d_sum(:, pcol.pDisagr_subwrong); wf.null=0.5;
    subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
    % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
    bar(wf.d, 'facecolor',[0.8 0.8 1])
    hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
    title('p(Disagree|Subject Wrong)','FontSize',f.fontsize_title), ylabel('proportion','FontSize',f.fontsize)
    % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
    wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d ), 'UniformOutput',0);
    set(gca,'ytick', 0:0.25:1,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 1])
    
 
   % ------------------------------------------------------------------------------------------------------------------------
     

    % Source Accuracy when sub Correct
    wf.d=  d_sum(:, pcol.pAcc_subright); wf.null=0.5;
    subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
    % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
        bar(wf.d, 'facecolor',[1 0.8 0.8])
    hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
    title('p(Acc|Subject Correct)','FontSize',f.fontsize_title), ylabel('proportion','FontSize',f.fontsize)
    % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
    wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d ), 'UniformOutput',0);
    set(gca,'ytick', 0:0.25:1,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 1])
    
    % Source Accuracy when sub Wrong
    wf.d=  d_sum(:, pcol.pAcc_subwrong); wf.null=0.5;
    subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
    % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
        bar(wf.d, 'facecolor',[1 0.8 0.8])
    hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
    title('p(Acc|Subject Wrong)','FontSize',f.fontsize_title), ylabel('proportion','FontSize',f.fontsize)
    % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
    wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d), 'UniformOutput',0);
    set(gca,'ytick', 0:0.25:1,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 1])


    
    % Source INAccuracy when sub Correct
    wf.d=  d_sum(:, pcol.pInacc_subright); wf.null=0.5;
    subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
    % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
        bar(wf.d, 'facecolor',[1 0.8 0.8])
    hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
    title('p(Inacc|Subject Correct)','FontSize',f.fontsize_title), ylabel('proportion','FontSize',f.fontsize)
    % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
    wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d ), 'UniformOutput',0);
    set(gca,'ytick', 0:0.25:1,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 1])
    
    % Source INAccuracy when sub Wrong
    wf.d=  d_sum(:, pcol.pInacc_subwrong); wf.null=0.5;
    subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
    % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
        bar(wf.d, 'facecolor',[1 0.8 0.8])
    hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
    title('p(Inacc|Subject Wrong)','FontSize',f.fontsize_title), ylabel('proportion','FontSize',f.fontsize)
    % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
    wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d), 'UniformOutput',0);
    set(gca,'ytick', 0:0.25:1,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 1])


    
    
    
    
    
    
    
    
    

end

for o=1:1 % Graphs coded as no. trials
    do_this =0;
    if do_this
        f.plotcols= 2;  f.plotrows=3;  f.figwidth= 1000; f.figheight=800; f.fontsize=13; f.fontsize_title=20;f.fontname='PT Sans Caption';
        f.subplot_VerHorz=[0.1 0.1]; f.fig_BotTop=[0.15 0.15]; f.fig_LeftRight=[0.1 0.05]; f.guidecolor=[0.1 0.1 0.1];
        figure('Name',  'Simulation stats', 'Position', [100 150 f.figwidth f.figheight], 'Color', 'w'); k=1;
        
        %         % Subject Accuracy
        %         wf.d=  d_sum(:, pcol.sub_acc); wf.null=0.5;
        %         subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        %         % barwitherr( std(wf.d)/sqrt(req.n_subs), mean(wf.d), 'facecolor',[0 0.8 0])
        %         bar(wf.d, 'facecolor',[0 0.8 0])
        %         hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
        %         title('Overall Subject Accuracy','FontSize',f.fontsize_title), ylabel('% Accurate','FontSize',f.fontsize)
        %         set(gca,'FontSize',f.fontsize); xlim([0.5 1.5]); ylim([0 1])
        %
        %
        %         % Subject pYes
        %         wf.d=  d_sum(:, pcol.sub_pyes); wf.null=0.5;
        %         subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        %         % barwitherr( std(wf.d)/sqrt(req.n_subs), mean(wf.d), 'facecolor',[0 0.8 0])
        %         bar(wf.d, 'facecolor',[0 0.8 0])
        %         hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
        %         title('Overall Subject Response Bias','FontSize',f.fontsize_title), ylabel('% Yes','FontSize',f.fontsize)
        %         set(gca,'FontSize',f.fontsize); xlim([0.5 1.5]);
        %
        %         % New row
        %         k=(ceil((k-1)/f.plotcols)*f.plotcols )+1;
        
        % ------------------------------------------------------------------------------------------------------------------------
        %
        %         % Source Accuracy
        %         wf.d=  d_sum(:, pcol.src_pAcc); wf.null=0.5*log.n_persrc;
        %         subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        %         % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
        %         bar(wf.d, 'facecolor',[0.8 0.8 1])
        %         hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
        %         title('Overall source accuracy','FontSize',f.fontsize_title), ylabel('No. trials Accurate','FontSize',f.fontsize)
        %         % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
        %         wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d ), 'UniformOutput',0);
        %         set(gca,'ytick', 0:10:log.n_persrc,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 log.n_persrc]);
        %
        %         % Source Agreement
        %         wf.d=  d_sum(:, pcol.src_pAgr); wf.null=0.5*log.n_persrc;
        %         subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        %         % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
        %         bar(wf.d, 'facecolor',[0.8 0.8 1])
        %         hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
        %         title('Overall source agreement','FontSize',f.fontsize_title), ylabel('No. Trials  Agree','FontSize',f.fontsize)
        %         % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
        %         wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d ), 'UniformOutput',0);
        %         set(gca,'ytick', 0:10:log.n_persrc,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 log.n_persrc]);
        
        % ------------------------------------------------------------------------------------------------------------------------
        % %
        %         % Source Agreement and sub Correct
        %         wf.d=  d_sum(:, pcol.pAgr_subright); wf.null=0.5*log.n_persrc;
        %         subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        %         % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
        %         bar(wf.d, 'facecolor',[0.8 0.8 1])
        %         hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
        %         title('No. Trials Agree And Subject Correct','FontSize',f.fontsize_title), ylabel('No. Trials','FontSize',f.fontsize)
        %         % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
        %         wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell(wf.d), 'UniformOutput',0);
        %         set(gca,'ytick', 0:10:log.n_persrc,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 log.n_persrc]);
        %
        %         % Source Agreement and sub Wrong
        %         wf.d=  d_sum(:, pcol.pAgr_subwrong); wf.null=0.5*log.n_persrc;
        %         subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        %         % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
        %         bar(wf.d, 'facecolor',[0.8 0.8 1])
        %         hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
        %         title('No. Trials Agree And Subject Wrong','FontSize',f.fontsize_title), ylabel('No. Trials','FontSize',f.fontsize)
        %         % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
        %         wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d ), 'UniformOutput',0);
        %         set(gca,'ytick', 0:10:log.n_persrc,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 log.n_persrc]);
        %
        %
        %         % Source Agreement and sub Correct
        %         wf.d=  d_sum(:, pcol.pDisagr_subright); wf.null=0.5*log.n_persrc;
        %         subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        %         % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
        %         bar(wf.d, 'facecolor',[0.8 0.8 1])
        %         hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
        %         title('No. Trials Disagree And Subject Correct','FontSize',f.fontsize_title), ylabel('No. Trials','FontSize',f.fontsize)
        %         % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
        %         wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell(wf.d), 'UniformOutput',0);
        %         set(gca,'ytick', 0:10:log.n_persrc,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 log.n_persrc]);
        %
        %         % Source Agreement and sub Wrong
        %         wf.d=  d_sum(:, pcol.pDisagr_subwrong); wf.null=0.5*log.n_persrc;
        %         subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        %         % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
        %         bar(wf.d, 'facecolor',[0.8 0.8 1])
        %         hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
        %         title('No. Trials Disagree And Subject Wrong','FontSize',f.fontsize_title), ylabel('No. Trials','FontSize',f.fontsize)
        %         % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
        %         wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d ), 'UniformOutput',0);
        %         set(gca,'ytick', 0:10:log.n_persrc,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 log.n_persrc]);
        %
        %         % ---------------------------------------------------------------------------
        %
        % Source Accuracy and sub Correct
        wf.d=  d_sum(:, pcol.pAcc_subright); wf.null=0.5*log.n_persrc;
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
        bar(wf.d, 'facecolor',[0.8 0.8 1])
        hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
        title('No. Trials Correct And Subject Correct','FontSize',f.fontsize_title), ylabel('No. Trials','FontSize',f.fontsize)
        % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
        wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d ), 'UniformOutput',0);
        set(gca,'ytick', 0:10:log.n_persrc,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 log.n_persrc]);
        
        % Source Accuracy when sub Wrong
        wf.d=  d_sum(:, pcol.pAcc_subwrong); wf.null=0.5*log.n_persrc;
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
        bar(wf.d, 'facecolor',[0.8 0.8 1])
        hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
        title('No. Trials Correct And Subject Wrong','FontSize',f.fontsize_title), ylabel('No. Trials','FontSize',f.fontsize)
        % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
        wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d), 'UniformOutput',0);
        set(gca,'ytick', 0:10:log.n_persrc,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 log.n_persrc]);
        
        % Source Accuracy when sub Correct
        wf.d=  d_sum(:, pcol.pInacc_subright); wf.null=0.5*log.n_persrc;
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
        bar(wf.d, 'facecolor',[0.8 0.8 1])
        hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
        title('No. Trials Wrong And Subject Correct','FontSize',f.fontsize_title), ylabel('No. Trials','FontSize',f.fontsize)
        % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
        wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d ), 'UniformOutput',0);
        set(gca,'ytick', 0:10:log.n_persrc,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 log.n_persrc]);
        
        % Source Accuracy when sub Wrong
        wf.d=  d_sum(:, pcol.pInacc_subwrong); wf.null=0.5*log.n_persrc;
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        % barwitherr(std(wf.d)/sqrt(req.n_subs), mean(wf.d),'y')
        bar(wf.d, 'facecolor',[0.8 0.8 1])
        hold on,   plot(0.5:size(wf.d,2)+0.5,  (0.5:size(wf.d,2)+0.5)*0+ wf.null, 'color',f.guidecolor)
        title('No. Trials Wrong And Subject Wrong','FontSize',f.fontsize_title), ylabel('No. Trials','FontSize',f.fontsize)
        % set(gca,'xticklabel',{'C','D','N', 'I'},'FontSize',f.fontsize); xlim([0.5 4.5]);
        wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( wf.d), 'UniformOutput',0);
        set(gca,'ytick', 0:10:log.n_persrc,'xticklabel', wf.xlabel,'FontSize',f.fontsize); xlim([0.5 4.5]); ylim([0 log.n_persrc]);
        
        
        
        %
        
    end
end
