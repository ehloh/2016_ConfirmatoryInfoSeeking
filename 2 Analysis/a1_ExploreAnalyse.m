% Free analysis
clear all, close all hidden, clc
% clear all, clc
 
% Subject sample -----
req.subjects={ };
% req.subjects={'A10LVHTF26QHQC';'A10XW6SNPNQX16';'A11W7R2O4RQSSS';'A13PXTFOXDCKBF';'A1489QNXV5IM6O';'A19JJ2RIRTWJOT';'A1A3TGZ7DKJWRW';'A1CH3TODZNQCES';'A1CPNA5L0J834N';'A1HK7CR71C8BCA';'A1OZPLHNIU1519';'A1P6OXEJ86HQRM';'A1SLJKNSNHOJRN';'A1TH0PTGDSBWMO';'A1VW8Y7XCV3DRW';'A1Y55YV1WA1TTD';'A1YPDVVWHZWDZ9';'A27O2IILV3S5YS';'A2C39KTRMOM1XZ';'A2C7TMRC2QHTIW';'A2DWPP1KKAY0HG';'A2FBT0BSFOV91D';'A2IHTAI46N1MDN';'A2JI3SCTFDSIUD';'A2OFRJHPNIMPI7';'A2OQZTSU48GRFG';'A2PXJTMWGUE5DC';'A2Q1YS118AO2BP';'A2RW1OV5XF3T26';'A2S4YDJ9UGAXFQ';'A2S5GPVIUV8RJI';'A2WU2OBJC98WQP';'A37KREDYGDTP4U';'A3AO2N7BNFDGF3';'A3B7TNVOISSZ2O';'A3DFJV1RD653DQ';'A3DS5B06ZCD3E3';'A3GPTSDDHJ2DBV';'A3ISDIYTS02E8C';'A3OSGGY6DR0N72';'A3T8J0PN3DLSTM';'A3T9C1USL4V4IJ';'A3UIDRGBV9NJWR';'A3UV9UAE6MP36J';'A3VBAQB2WO36Q1';'A7PBWBAHT4RJ';'ACNID00UIEL1T';'ADKKDK6P4MS1Z';'AIPHJXQEDNW9L';'AK7LGB1QOGA1P';'AMPMTF5IAAMK8';'ARM2CBQGJCQ5Z';'AY7WPVKHVNBLG'}

    
% Task 
req.taskversion='v3_3';    

for o=1:1 % General
    
    
    % Misc requestables  
    req.afc_threshold = 1;  % Note: this can be lower, but not higher, than actual 
    
     
    % Where
    w.w=pwd; if strcmp(w.w(1), '/')==0;  where.where ='C:\Users\e.loh\Dropbox\SCRIPPS\3_ConfirmInfo\'; else  where.where ='/Users/EleanorL/Dropbox/SCRIPPS/3_ConfirmInfo/';  end
    where.data=[where.where '3 Data' fs req.taskversion fs];   
    where.scripts= [where.where '4 Analysis'];   addpath(where.scripts); cd(where.data)
    rand('state',sum(100*clock));    
    fmat= @(mat, index)mat(index);
    fvect= @(mat)mat(:);
    f_vecshuffle=  @(x)fmat(fvect(sortrows([fvect(x) rand(length(x),1)],2)), 1:length(x));
    f_sig=@(p)fmat(sortrows(repmat([1 0.5 zeros(1,18)]',500,1), -1), find(ceil((p+eps)*100)/100<=linspace(0.001, 1, length(repmat([1 0.5 zeros(1,18)]',500,1))),1,'first')-1);   % Convert p value to significane marker: 1 (p<=0.05), 0.5 (p<.1), 0. p values below 0.01 are treated as 0.01 for the sake of indexing
    f_binflip= @(x)abs(1-x);  
    ftime =@(x,y)[str2num(y(fmat(strfind(y,':'),1)-2:fmat(strfind(y,':'),1)-1))-str2num(x(fmat(strfind(x,':'),1)-2:fmat(strfind(x,':'),1)-1))   str2num(y(fmat(strfind(y,':'),1)+1:fmat(strfind(y,':'),1)+2)) - str2num(x(fmat(strfind(x,':'),1)+1:fmat(strfind(x,':'),1)+2))];  % Returns Difference in hours and min, when fed javascript timestamp format ('2016-11-23T16:15:04.696Z'). Min can be negative, in which case: increment hour 
    req.preproc={}; req.alter = {};  
     
    % Subjects
    w.d=dir('A*');  if size(w.d,1)<1, w.d=dir('p*');  end  
    logg.subjects=fmat(cellstr(char(w.d.name)), find(cellfun(@(x)exist(x,'dir')==7,  cellstr(char(w.d.name)) ) .*cellfun(@(x)strcmp(x(1),'.')==0,  cellstr(char(w.d.name)) ) ));  
    if isempty(req.subjects)==0; logg.subjects= logg.subjects(find(cell2mat(cellfun(@(t,s)sum(strcmp(t,s)),  logg.subjects(:)', repmat({req.subjects(:)}, 1, length(logg.subjects(:))), 'UniformOutput',0)))); end
    logg.n_subjs = length(logg.subjects); subjdata = cell(logg.n_subjs , 5); d_self=nan(logg.n_subjs, 3);  
    
    % Duplicate single subjects to allow for plotting? 
    if logg.n_subjs==1
        disp('Single subject requested. Duplicating data to allow plotting'); input('Continue?  '); 
        logg.subjects= [logg.subjects;logg.subjects]; 
        logg.n_subjs=length(logg.subjects);
    end 
    
    % Misc settings 
    logg.acqsess_srcpairs=[1 2; 1 3; 1 4; 2 3; 2 4; 3 4]; % From acquisition script 
    logg.chk_q.qtype = {'Own', 'Info', 'Sourc','OwnAcc','SrcAcc'}; 
    logg.srccomp={'CD' [1 2]; 'CN' [1 3]; 'DN' [2 3]; 'CI' [1 4]; 'DI' [2 4]; 'NI' [3 4]};
    logg.srccolors={'y', 'c', [1 0.4 0],'m'};  % C D N I
    for p=1:size(logg.srccomp,1) 
        logg.srccomp{p,3} =[(p-1)*2.5+1.4  (p-1)*2.5+2 (p-1)*2.5+2.6];
%         logg.srccomp{p,3} =[(p-1)*3+2-0.6  (p-1)*3+2 (p-1)*3+2+0.6];
        logg.srccomp{p,4} ={[0.2 0.2 0.2] logg.srccolors{logg.srccomp{p,2}(1)} logg.srccolors{logg.srccomp{p,2}(2)} };
    end
    req.srcomp_xtick =  [logg.srccomp{1,3}(2) logg.srccomp{2,3}(2) logg.srccomp{3,3}(2) logg.srccomp{4,3}(2) logg.srccomp{5,3}(2) logg.srccomp{6,3}(2)]; 
    logg.src_ppcomp={'CN vs DN' [2 3]; 'CI vs DI' [4 5]; 'CI vs NI' [4 6]; 'DI vs NI' [5 6]}; % Assumes order of PP columns as in logg.srccomp

    % Data store variables 
    df_simpcho{1} = [{'C';'D';'N';'I'} cell(4,1)];
    df_simpair_pcho{1}  = logg.srccomp(:,1); 
    df_simacc{1} = nan(logg.n_subjs,4); 
    df_simaccnoi{1} = nan(logg.n_subjs,4);    
    df_pass{1} =nan(logg.n_subjs,2); 
    dr_ratesource=cell(1,1);  
end

% disp('Artificially up n (to check scripting)'),  logg.subjects =repmat(logg.subjects,5,1); logg.n_subjs = length(logg.subjects);

%% Load + mark data 

% Simulation
req.redo.learning= 0;
req.redo.choice= 0;  

for s=1:logg.n_subjs   % Load data
    ws.f1=  load([where.data logg.subjects{s} fs logg.subjects{s} '_1Learn.mat']);    ws.d1= ws.f1.data;  ws.df =  ws.f1.df_data;  % df = afc data from learning stage 
    ws.f2=  load([where.data logg.subjects{s} fs logg.subjects{s} '_2Choose.mat']);    ws.d2= ws.f2.data;
    ws.f3=  load([where.data logg.subjects{s} fs logg.subjects{s} '_3Rate.mat']);     ws.d3_src= ws.f3.ds_data; ws.d3_self= ws.f3.dp_data;  
    
    for o=1:1  % Load settings  
        if s==1;
            coll= ws.f1.col;  colc= ws.f2.col; colr= ws.f3.colds; colrp= ws.f3.coldp; colf=  ws.f1.coldf; % coll= learn, colc= choice, colr= rate source, colrp = rate self/participant, colf = 2AFC during learning
            coll.acc= coll.outcome;  % Adaptations to make cols accessible via instructions
            coll.outcome1=coll.outcome;
            coll.choice1=coll.choice;
            coll.choice2=coll.choice;
            colc.chosource= colc.chosrc; 
            colc.source= colc.chosrc; 
            
            % Additional new columns
            coll.choconf= structmax(coll)+1;
            coll.randx=structmax(coll)+1; 
            colc.cho2agree =structmax(colc)+1;
%             colc.choconf1=structmax(colc)+1;
%             colc.choconf2= structmax(colc)+1;
%             colc.choconfdiff= structmax(colc)+1;
%             colc.convertdist= structmax(colc)+1;   % Choose-confidence points of conversion (relative to info)
%             colc.convertcat= structmax(colc)+1;   % Choice-conversion (Binary)
            colc.srcpair= structmax(colc)+1;
            colc.srcagree= structmax(colc)+1;
            colc.choswitch= structmax(colc)+1; 
            colf.trialnum = structmax(colf)+1; 
            colf.acc = structmax(colf)+1;  
            colf.src1 = structmax(colf)+1;  
            colf.src2 = structmax(colf)+1;  
            colf.testblk = structmax(colf)+1;  
            colf.blkacc = structmax(colf)+1;
            colf.srcpair= structmax(colf)+1;
             
            colc.srcacc= structmax(colc)+1;  % Dummy variables  
            colc.outcome= structmax(colc)+1; 
            colc.outcome1= structmax(colc)+1; 
            colc.trialnum= structmax(colc)+1;    
            colc.outcome2= structmax(colc)+1;    
            
            % More accessible col holders
            col.s={coll colc colr}; coll = col.s{1}; colc = col.s{2}; colr = col.s{3};
            
            % Ground-level data for Checks (everything hard coded) d_checks 
            colck.q=1;              % First 4 things are hard coded. 
            colck.truefalse=2; 
            colck.trial=3; 
            colck.qtype=4;  % See logg.chk_qtype: 1= Own, 2 = Info, 3= Source, 4= SubAcc, 5=SrcAcc
            colck.acc = structmax(colck)+1;  
            colck.td_col = structmax(colck)+1;
            colck.td_val = structmax(colck)+1;   
            
            % Subject meta-scores (indiv diff, e.g. rating of own performance)
            logg.qs_self =cell(length(fieldnames(ws.f3.log.rateself_qs)), 5);  
            for i = 1:length(fieldnames(ws.f3.log.rateself_qs))
                logg.qs_self{i,1} = char(fmat(fieldnames(ws.f3.log.rateself_qs), i)); 
                eval(['logg.qs_self(i,2:4)=ws.f3.log.rateself_qs.' char(logg.qs_self{i,1}) ';']) 
                eval(['colslf.'  logg.qs_self{i,1} ' = ' num2str(i) ';'])  % Columns for d_self  
            end   
            colslf.probscore= structmax(colslf)+1;      % Likely score (choice stage) 
            colslf.checklearn= structmax(colslf)+1;     % Learning checks 
            colslf.checkchoice= structmax(colslf)+1;    % Choice checks 
            colslf.checkall= structmax(colslf)+1;      % Learn + Choice checks 
            logg.src =  ws.f1.log.Src.condition; 
            logg.srcacc =  [ws.f1.log.pCorrect.C; ws.f1.log.pCorrect.D; ws.f1.log.pCorrect.N; ws.f1.log.pCorrect.I]; % Row = Src, Col = Disagree, Agree             
            logg.chk_q.learn =  ws.f1.log.catch_qs';
            logg.chk_q.choice=  ws.f2.log.catch_qs'; 
        end
    end   
    for o=1:1   % Fill in source pairs for all pairings
        % Note: Acquisition source pairs and the source pair allocation used in analysis are DIFFERENT. 
        %       Here, standardize all sourcepair allocations to be analysis-stage allocations (logg.srccomp) 
        
        % Learning stage AFC  
        ws.df(:,colf.src1)=cellfun(@(x)fmat(ws.f1.log.srcpair_src(:,1),x), num2cell(ws.df(:,colf.acqsrcpair))); % Use acq source pair allocation when mapping from acq-srcpairs to sources 
        ws.df(:,colf.src2)=cellfun(@(x)fmat(ws.f1.log.srcpair_src(:,2),x), num2cell(ws.df(:,colf.acqsrcpair))); 
        for c=1:6
            ws.df((ws.df(:, colf.src1)==logg.srccomp{c,2}(1)) & (ws.df(:, colf.src2)==logg.srccomp{c,2}(2)), colf.srcpair)=c;
            ws.df((ws.df(:, colf.src1)==logg.srccomp{c,2}(2)) & (ws.df(:, colf.src2)==logg.srccomp{c,2}(1)), colf.srcpair)=c; 
        end  
        
        % Choice stage 
        for c=1:6
            ws.d2((ws.d2(:, colc.src1)==logg.srccomp{c,2}(1)) & (ws.d2(:, colc.src2)==logg.srccomp{c,2}(2)), colc.srcpair)=c;
            ws.d2((ws.d2(:, colc.src1)==logg.srccomp{c,2}(2)) & (ws.d2(:, colc.src2)==logg.srccomp{c,2}(1)), colc.srcpair)=c; 
        end    
        
    end
    
%     
%     if s==1; disp('FAKE DATA!'); end 
%     
%     ws.dd =  ws.d2(ws.d2(:, colc.srcpair)==2, [colc.src1 colc.src2]); 
%     
%     
%     ws.dd 
%      
%     
%     
%     ws.d2(ws.d2(:, colc.srcpair)==3, [colc.src1 colc.src2])
%      
%     
    
    
    
    ws.d2(:,colc.trialnum)=1:size(ws.d2,1); 
      
    % [ DEBUGGING FAKE DATA ] ------------------------------------------------------------------------------------------
    for o1=1:1
    %   if s==1, disp('FAKE DATA DEBUGIGN'); end
%     % ws.d2(:, colc.chosrc)=  randi(4, size(ws.d2,1),1);
%     ws.d2=[];
%     ws.d2(:, colc.chosrc) = d(:,1);
%     ws.d2(:, colc.choice1) = d(:,2);
%     ws.d2(:, colc.choice2) = d(:,3);
%     ws.d2(:, colc.info) = d(:,4); 
%     for t=1:size(ws.d2,1) 
%         ws.d2(t, colc.srcpair) = fmat([find(logg.acqsess_srcpairs(:,1)==ws.d2(t, colc.chosrc)); find(logg.acqsess_srcpairs(:,2)==ws.d2(t, colc.chosrc))],randi(3)); disp('THIS IS WRONG. Src Pair allocation is all analysis-stage src pairs, not acq-stage')
%     end
%     %
%     ws.d2(:, colc.srcagree) = ws.d2(:, colc.choice1) ==ws.d2(:, colc.info) ; 
%     ws.d2(:, colc.cho2agree) = ws.d2(:, colc.choice2) ==ws.d2(:, colc.info) ; 
%     ws.d2(:, colc.choswitch) = ws.d2(:, colc.choice2)~=ws.d2(:, colc.choice1) ; 
    end
    
    % [ SIMULATION ] ------------------------------------------------------------------------------------------
    for o1=1:1    
        if s==1 && req.redo.learning+req.redo.choice > 1; input('REQUESTED simulation. OK?  '); end;  
        % Learning stage
        if req.redo.learning; if s==1; req.alter{length(req.alter)+1}= '[LEARNING stage]: Re-doing info to SOME degree'; end
            %         if s==1; req.alter{length(req.alter)+1} ='    [ALTER p ] More extreme probabilities';  logg.pyes.C.t1s1 = 9/10;  logg.pyes.C.t1s0 = 6/10;   logg.pyes.C.t0s1 = 2/10;  logg.pyes.C.t0s0 = 1/10;   logg.pyes.D.t1s1 = 6/10;  logg.pyes.D.t1s0 = 9/10;   logg.pyes.D.t0s1 = 1/10;  logg.pyes.D.t0s0 = 2/10;   logg.pyes.N.t1= 0.8;  logg.pyes.N.t0= 0.2;  end
%                     if s==1, req.alter{length(req.alter)+1} ='    [ALTER n] Up-sampling n trials'; end ; ws.d1=repmat(ws.d1, 10);
%             if s==1; req.alter{length(req.alter)+1} ='    [ALTER Choice] Choice is redone (randomly)'; end;   ws.d1(:, coll.choice) =  2-randi(2, size(ws.d1,1),1);
            %         if s==1, req.alter{length(req.alter)+1} ='    [ALTER Random] Random numbers redone - Matlab Rand'; end; ws.d1(:, coll.randx) = rand(size(ws.d1,1),1);
            %         if s==1; req.alter{length(req.alter)+1} ='    [ALTER Random] Uniform +  drawn eq across sources'; end;   for i=1:4, ws.d1(ws.d1(:, coll.source)==i, coll.randx)=linspace(eps, 1-eps, sum(ws.d1(:, coll.source)==i))';   end
            
            % Implement implications
            ws.dp= zeros(size(ws.d1,1),1);
            for tn=1:size(ws.d1,1)  % Load probabilities
                if ws.d1(tn, coll.source)>0,  ws.dp(tn,1) = logg.pyes{ws.d1(tn, coll.source)}(ws.d1(tn,coll.truth)+1, ws.d1(tn,coll.choice)+1); end
            end
            ws.d1(:, coll.info) = ws.d1(:, coll.randx)<ws.dp;
            ws.d1(:, coll.outcome) = ws.d1(:, coll.truth) ==ws.d1(:, coll.choice);
            ws.d1(:, coll.srcacc)= ws.d1(:, coll.truth)==ws.d1(:, coll.info);
            
            % Manually calculate stats
            ws.d1= sortrows(ws.d1, [coll.source coll.truth coll.choice coll.randx coll.info]);
            a=[ws.d1(:, [coll.source coll.truth coll.choice coll.info])  ws.dp ws.d1(:, coll.randx)]; a= sortrows(a, [1 2 3 4 6]);
            a(a(:,1)==0,:)=[]; % source, truth, choice, info
        end
        
        % Choice stage
        for o2=1:1 % Defaults for simulations
            if s==1, req.redo.pcho2agree_persrc =0; end
            if s==1, req.redo.chosrc =0; end 
            if s==1, req.redo.pcho2agree_agrdisagree_persrc  =0; end 
        end
        if req.redo.choice; if s==1; req.alter{length(req.alter)+1}= '[CHOICE stage] Re-doing info to SOME degree'; end;   if s==1, disp('FLAG: Be careful, don''t combine too many simulations as they will interact and fuck things up'), end; ws.od2=  ws.d2;   
            %         if s==1; req.alter{length(req.alter)+1} ='    [ALTER p ] More extreme probabilities';  logg.pyes.C.t1s1 = 9/10;  logg.pyes.C.t1s0 = 6/10;   logg.pyes.C.t0s1 = 2/10;  logg.pyes.C.t0s0 = 1/10;   logg.pyes.D.t1s1 = 6/10;  logg.pyes.D.t1s0 = 9/10;   logg.pyes.D.t0s1 = 1/10;  logg.pyes.D.t0s0 = 2/10;   logg.pyes.N.t1= 0.8;  logg.pyes.N.t0= 0.2;  end
                    if s==1, req.alter{length(req.alter)+1} ='    [ALTER n] Up-sampling n trials'; end ; ws.d2=repmat(ws.d2, 50);
%             if s==1; req.alter{length(req.alter)+1} ='    [ALTER Choice1] Choice1 is redone (randomly)'; end;   ws.d2(:, colc.choice1) =  2-randi(2, size(ws.d2,1),1);            
%             if s==1; req.alter{length(req.alter)+1} ='    [ALTER Choice1] Choice1 always yes'; end;   ws.d2(:, colc.choice1) =  1;
            %         if s==1, req.alter{length(req.alter)+1} ='    [ALTER Random] Random numbers redone - Matlab Rand'; end; ws.d2(:, colc.randx) = rand(size(ws.d2,1),1);
%             if s==1; req.alter{length(req.alter)+1} ='    [ALTER Random] Uniform +  drawn eq across sources'; end;   for i=1:4, ws.d2(ws.d2(:, colc.source)==i, colc.randx)=linspace(eps, 1-eps, sum(ws.d2(:, colc.source)==i))';   end
%             if s==1; req.alter{length(req.alter)+1} ='    [ALTER Choice1&2] Choice1&2 are redone (randomly)'; end;   disp('THIS SIM IS NOT YET FIGURED OUT YET. Info has to be recalculated.')
            if s==1; req.alter{length(req.alter)+1} ='    [ALTER Choice2] Choice2 redone: p(follow) = .5'; end; for t=1:size(ws.d2,1);   if round(rand),  ws.d2(t, colc.choice2) = ws.d2(t, colc.info);  else ws.d2(t, colc.choice2) = 1-ws.d2(t, colc.info);   end;  end    
%             if s==1; req.alter{length(req.alter)+1} ='    [ ALTER ChoSrc] Choose between 4 sources equally'; end;  k=1;  for t=1:size(ws.d2,1); if ws.d2(t, colc.src1)>0, ws.d2(t,colc.chosrc)=k; k=k+1;  if k==5, k=1; end;   end; end; req.redo.chosrc =1;   
            ws.ChoSrc=[1 1 1 1 2 2 3 3];k=1;   if s==1; req.alter{length(req.alter)+1} ='    [ ALTER ChoSrc] Redo Source Choice'; end;  for t=1:size(ws.d2,1);  if ws.d2(t, colc.src1)>0, ws.d2(t,colc.chosrc)=ws.ChoSrc(k); k=k+1;  if k==length(ws.ChoSrc), k=1; end;   end;  end;  req.redo.chosrc =1;  
            ws.pFollowInfo=[1 0.8 0.6 0.4]; if s==1; req.alter{length(req.alter)+1} = ['    [ALTER Choice2] Choice2 follows info roughly =' num2str(ws.pFollowInfo) ' (C,D,N,I)']; end;   req.redo.pcho2agree_persrc =1; 
%             ws.pSwitchAgree=[0.1 0.1 0.1 0.1];  ws.pSwitchDis =[0.9 0.8 0.7 0.6]; 
%             ws.pSwitchAgree=[0.1 0.2 0.3 0.4];  ws.pSwitchDis =[0.9 0.9 0.9 0.9];  if s==1; req.alter{length(req.alter)+1} = ['    [ALTER Choice2] Choice2 follows info (split by Agree/Disagree) roughly  ' num2str([ws.pSwitchAgree nan  ws.pSwitchDis]) ' (C,D,N,I)']; end;   req.redo.pcho2agree_agrdisagree_persrc =1; 
%              if s==1; req.alter{length(req.alter)+1} ='    [ALTER Choice2] Choice2 follows info always'; end; ws.d2(:,colc.choice2) = ws.d2(:, colc.info);   disp('WARNINNG I THINK CODE IS WRONG) Check w pFollowInfo=[1 1 1 1];')
             
 
            % Choice of info
%             if s==1; req.alter{length(req.alter)+1}= '    [Choice stage] Choose source C>D>N>I'; end;   ws.d2(1:round(size(ws.d2,1)*0.9), colc.source) =  min( ws.d2(1:round(size(ws.d2,1)*0.9), [colc.chosrc colc.src2]) ,[] ,2); ws.d2(round(size(ws.d2,1)*0.9):end, colc.source) =  max( ws.d2(round(size(ws.d2,1)*0.9):end, [colc.chosrc colc.src2]) ,[] ,2);
 
            %         % Manually calculate stats
            %         ws.d2= sortrows(ws.d2, [colc.source colc.truth colc.choice1 colc.randx colc.info]);
            %         a=[ws.d2(:, [colc.source colc.truth colc.choice1 colc.info])  ws.dp ws.d2(:, colc.randx)]; a= sortrows(a, [1 2 3 4 6]);
            %         a(a(:,1)==0,:)=[]; % source, truth, choice, info  
            
            
              
             
            % Implement changes to choice of source
            if  req.redo.chosrc
                ws.od2(:, colc.srcagree) = ws.od2(:, colc.choice1) ==ws.od2(:, colc.info) ;
                ws.od2(:, colc.cho2agree) = ws.od2(:, colc.choice2) ==ws.od2(:, colc.info) ;
                ws.od2(:, colc.choswitch) = ws.od2(:, colc.choice2)~=ws.od2(:, colc.choice1) ;
                ws.d2(:, colc.randx) = nan;
                for sr=1:4
                    
                    % What are the current agreement rates? Keep them
                    %   (This passes on the chance-errors from acq to the simulation)
                    wc.od =  ws.od2( ws.od2(:, colc.chosrc)==sr, :);
                    wc.od_agree = wc.od(wc.od(:, colc.srcagree)==1,:);
                    wc.od_disagr= wc.od(wc.od(:, colc.srcagree)==0,:);
                    ws.orig_srcagree(sr) =   mean(wc.od(:, colc.srcagree));   % How much does the source generally agree w you?
                    ws.choswitch_agr=       mean(wc.od_agree(:, colc.choswitch));
                    ws.choswitch_disagr=    mean(wc.od_disagr(:, colc.choswitch));
                    
                    % Decide on new info: based on choice 1, what should the source say, given its propensity to agree?
                    wc.d =  ws.d2( ws.d2(:, colc.chosrc)==sr, :);
                    wc.d(:, colc.srcagree) = f_vecshuffle(linspace(0,1, size(wc.d,1))<=ws.orig_srcagree(sr));
                    wc.d(wc.d(:, colc.srcagree)==1, colc.info) = wc.d(wc.d(:, colc.srcagree)==1, colc.choice1);
                    wc.d(wc.d(:, colc.srcagree)==0, colc.info) = abs(wc.d(wc.d(:, colc.srcagree)==0, colc.choice1)-1);
                    
                    % Based on (awhether the source agreed/disagreed, and based on how the subjects generally respond to this sources's (dis)agreement, should they switch?
                    wc.d(wc.d(:, colc.srcagree)==1, colc.choswitch)=f_vecshuffle(linspace(0,1, sum(wc.d(:, colc.srcagree)==1))<=  ws.choswitch_agr);   % Do they switch?
                    wc.d(wc.d(:, colc.srcagree)==0, colc.choswitch)=f_vecshuffle(linspace(0,1, sum(wc.d(:, colc.srcagree)==0))<=  ws.choswitch_disagr);
                    wc.d(wc.d(:, colc.choswitch)==0, colc.choice2) = wc.d(wc.d(:, colc.choswitch)==0, colc.choice1);
                    wc.d(wc.d(:, colc.choswitch)==1, colc.choice2) = abs(wc.d(wc.d(:, colc.choswitch)==1, colc.choice1)-1);
                    
                    % Look at manually
                    wc.d=sortrows(wc.d, [colc.srcagree colc.choswitch colc.choice1]);
                    %                 wc.d(:, [colc.choice1  colc.info colc.srcagree colc.randx  colc.choice2   colc.choswitch])
                    %                 disp([logg.src{sr} '               Original   Simulated data'])
                    %                 disp(['Src Agree:            ' num2str([ws.orig_srcagree(sr)   mean(wc.d(:, colc.srcagree))])])
                    %                 disp(['Switch|Src Agree:     '  num2str([ws.choswitch_agr  mean(wc.d(wc.d(:, colc.srcagree)==1, colc.choswitch)) ])])
                    %                 disp(['Switch|Src Disagree:  ' num2str([ws.choswitch_disagr  mean(wc.d(wc.d(:, colc.srcagree)==0, colc.choswitch))])])
                     
                    % Put back 
                    ws.d2( ws.d2(:, colc.chosrc)==sr, :)=wc.d;
                end
            end  
             for o2=1:1  % Cho2 alterations that can't fit in 1 line  
                if req.redo.pcho2agree_persrc   
                    % Note: This allocation does not deterministically determine subjects scores - i.e. there will still be some spread around the mean,
                    %   in the p(Switch) figures, because the re-allocation of Cho2Agree, while overall set by the requested probabilities, is randomly set 
                    %   wrt whether that trial is a Src-Agree or Src-Disagree trial. If you upsample massively the spread gets smaller to eliminate this, 
                    %   but this is the source of the stochasticity here  
                    for sr=1:4; 
                        wc.d=  ws.d2(ws.d2(:, colc.chosource)==sr, :);  
                        wc.d(:, colc.cho2agree) =  f_vecshuffle(linspace(0,1, size(wc.d,1))<=ws.pFollowInfo(sr));  
                        wc.d(wc.d(:, colc.cho2agree)==1, colc.choice2)=     wc.d(wc.d(:, colc.cho2agree)==1, colc.info); 
                        wc.d(wc.d(:, colc.cho2agree)==0, colc.choice2)= abs(wc.d(wc.d(:, colc.cho2agree)==0, colc.info)-1);  
                        ws.d2(ws.d2(:, colc.chosource)==sr, :) = wc.d;   
                    end 
                end 
                if req.redo.pcho2agree_agrdisagree_persrc  %pAgree given Src Agree/Disagree 
                    ws.d2(:, colc.srcagree) = ws.d2(:, colc.choice1) ==ws.d2(:, colc.info) ;   
                    for sr=1:4 
                        ws.d2( ws.d2(:, colc.chosource)==sr & ws.d2(:, colc.srcagree)==1, colc.choswitch)= f_vecshuffle(linspace(0,1,sum(ws.d2(:, colc.chosource)==sr & ws.d2(:, colc.srcagree)==1))<=ws.pSwitchAgree(sr));
                        ws.d2( ws.d2(:, colc.chosource)==sr & ws.d2(:, colc.srcagree)==0, colc.choswitch)= f_vecshuffle(linspace(0,1,sum(ws.d2(:, colc.chosource)==sr & ws.d2(:, colc.srcagree)==0))<=ws.pSwitchDis(sr)); 
                    end  
                    ws.d2(ws.d2(:, colc.choswitch)==0, colc.choice2)=ws.d2(ws.d2(:, colc.choswitch)==0, colc.choice1);
                    ws.d2(ws.d2(:, colc.choswitch)==1, colc.choice2)=f_binflip(ws.d2(ws.d2(:, colc.choswitch)==1, colc.choice1)); 
                    ws.d2(:, colc.cho2agree) = ws.d2(:, colc.info) ==ws.d2(:, colc.choice2); 
                end
            end 
            
            
            % Implement implications of changes to Choice1/2            
            ws.d2(:, colc.srcagree) = ws.d2(:, colc.choice1) ==ws.d2(:, colc.info) ;   
            ws.d2(:, colc.cho2agree) = ws.d2(:, colc.choice2) ==ws.d2(:, colc.info) ;
            ws.d2(:, colc.choswitch) = ws.d2(:, colc.choice2)~=ws.d2(:, colc.choice1) ; 
        end  % End for 
    end
     
   % [ DUMMY VARIABLES ]  ------------------------------------------------------------------------------------------
    for o1=1:1  % Confidence scores - turned off for now
        % Fill in fake confidence ratings (to make scripts run)
%         if s==1; req.alter{length(req.alter)+1} ='[Everything] Fake confidence ratings!';   end ; ws.d2(:,[colc.choconf1 colc.choconf2])= ones( size(ws.d2,1),2);  ws.d1(:,coll.choconf) =ones(size(ws.d1,1),1);
        
        % Choice-confidence scores (1=VSureNo, 2=SureNo, 3=GuessNo, 4=GuessYes, 5=SureYes, 6=VSureYes)
        %     ws.d2( ws.d2(:, coll.choice)==0  & ws.d2(:, coll.confidence)==3, coll.choconf)= 1;
        %     ws.d2( ws.d2(:, coll.choice)==0  & ws.d2(:, coll.confidence)==2, coll.choconf)= 2;
        %     ws.d2( ws.d2(:, coll.choice)==0  & ws.d2(:, coll.confidence)==1, coll.choconf)= 3;
        %     ws.d2( ws.d2(:, coll.choice)==1  & ws.d2(:, coll.confidence)==1, coll.choconf)= 4;
        %     ws.d2( ws.d2(:, coll.choice)==1  & ws.d2(:, coll.confidence)==2, coll.choconf)= 5;
        %     ws.d2( ws.d2(:, coll.choice)==1  & ws.d2(:, coll.confidence)==3, coll.choconf)= 6;
        %     ws.d3( ws.d3(:, colc.choice1)==0 & ws.d3(:, colc.confidence1)==3, colc.choconf1)= 1;
        %     ws.d3( ws.d3(:, colc.choice1)==0 & ws.d3(:, colc.confidence1)==2, colc.choconf1)= 2;
        %     ws.d3( ws.d3(:, colc.choice1)==0 & ws.d3(:, colc.confidence1)==1, colc.choconf1)= 3;
        %     ws.d3( ws.d3(:, colc.choice1)==1 & ws.d3(:, colc.confidence1)==1, colc.choconf1)= 4;
        %     ws.d3( ws.d3(:, colc.choice1)==1 & ws.d3(:, colc.confidence1)==2, colc.choconf1)= 5;
        %     ws.d3( ws.d3(:, colc.choice1)==1 & ws.d3(:, colc.confidence1)==3, colc.choconf1)= 6;
        %     ws.d3( ws.d3(:, colc.choice2)==0 & ws.d3(:, colc.confidence2)==3, colc.choconf2)= 1;
        %     ws.d3( ws.d3(:, colc.choice2)==0 & ws.d3(:, colc.confidence2)==2, colc.choconf2)= 2;
        %     ws.d3( ws.d3(:, colc.choice2)==0 & ws.d3(:, colc.confidence2)==1, colc.choconf2)= 3;
        %     ws.d3( ws.d3(:, colc.choice2)==1 & ws.d3(:, colc.confidence2)==1, colc.choconf2)= 4;
        %     ws.d3( ws.d3(:, colc.choice2)==1 & ws.d3(:, colc.confidence2)==2, colc.choconf2)= 5;
        %     ws.d3( ws.d3(:, colc.choice2)==1 & ws.d3(:, colc.confidence2)==3, colc.choconf2)= 6;
        %
        %     % Conversion rates
        %     ws.d3(:, colc.choconfdiff)= ws.d3(:, colc.choconf2)-ws.d3(:, colc.choconf1);
        %     ws.d3(:, colc.convertdist)= ws.d3(:, colc.choconfdiff).*(ws.d3(:, colc.info)*2-1);   % No. pts that source manages to move subject. Calculation: ChoConfDiff * Info (+/-1)   [i.e. -1 if Info=No, +1 if Info=Yes]        
    end
    ws.d1(:, coll.randx)=nan;  % No random number variable for Learning stage (pre-allocated) 
    ws.d2(:, [colc.srcacc  colc.outcome  colc.outcome1 colc.outcome2])=nan;  
    %     disp('WARNING: FAKE RTS!!!!'); ws.d1(:,coll.rt)= rand(size(ws.d1,1),1)*500;  ws.d2(:,[colc.rt1 colc.rt2 colc.chosrcRT])= rand(size(ws.d2,1),3)*500
    % ---------------------------------------------------------------------------------------------------------
     
    % [ ALTERATIONS ] ------------------------------------------------------------------------------------------
    %    if s==1; req.alter{length(req.alter)+1}='Sub-sample hard trials'; end;
    
    
    % [ PREPROCESSING ]  ------------------------------------------------------------------------------------------ 
    ws.d2(ws.d2(:, colc.src1)>0, colc.cho2agree) =  ws.d2(ws.d2(:, colc.src1)>0, colc.info)== ws.d2(ws.d2(:, colc.src1)>0, colc.choice2);      
%     ws.d2(:, colc.convertcat)=nan;  ws.SE2info = find(ws.d2(:, colc.srcpair)>0);      % Does source manage to (binary) convert subject? Calculation:  Choice mismatch (1/0) x  Info-Cho2 mismatch (+1/-1)
%     ws.d2(ws.SE2info, colc.convertcat)= (   ws.d2(ws.SE2info, colc.choice1)==ws.d2(ws.SE2info, colc.choice2)  ) .* (   2*(ws.d2(ws.SE2info, colc.info)==ws.d2(ws.SE2info, colc.choice2))-1   );
    ws.d2(ws.d2(:, colc.src1) >0, colc.srcagree) = ws.d2(ws.d2(:, colc.src1) >0, colc.choice1) == ws.d2(ws.d2(:, colc.src1) >0, colc.info); 
    ws.d2(ws.d2(:, colc.src1)>0,  colc.choswitch)= ws.d2(ws.d2(:, colc.src1)>0,  colc.choice1)~=ws.d2(ws.d2(:, colc.src1)>0,  colc.choice2);
 
    % Trim learning trials: only what the subjects experienced 
    ws.d1 = ws.d1(~isnan(ws.d1(:, coll.choice)),:);  % Delete  
    
    % Score 2AFC during learning   
%     for t=1:size(ws.df,1), ws.df(t, colf.cho) = fmat(ws.f1.log.srcpair_src(ws.df(t, colf.srcpair),:),randi(2));   end; disp('FAKE RANDOM AFC')  
    ws.df(:,colf.trialnum)=1:size(ws.df,1);  
    ws.df(:,colf.testblk)= cellfun(@(x)find(x== unique(ws.df(:,1))), num2cell(ws.df(:,colf.blk))); 
    if s==1, ws.srcpair =  [ws.f1.log.srcpair_src(:,1) ws.f1.log.srcpair_src(:,2)];  if sum([[ws.srcpair(1,1) ws.srcpair(1,2)] - [ 1 2]])+sum([[ws.srcpair(2,1) ws.srcpair(2,2)] - [ 1 3]])+sum([[ws.srcpair(3,1) ws.srcpair(3,2)] - [ 1 4]])+sum([[ws.srcpair(4,1) ws.srcpair(4,2)] - [ 2 3]])+ sum([[ws.srcpair(5,1) ws.srcpair(5,2)] - [ 2 4]])+sum([[ws.srcpair(6,1) ws.srcpair(6,2)] - [ 3 4]]) >0; disp('WARNING: 2AFC source pair allocation is not as expected!'); end, end 
    ws.df(ws.df(:,colf.acqsrcpair)==1, colf.acc)= ws.df(ws.df(:,colf.acqsrcpair)==1, colf.cho)==1; % C vs D --> C (1)
    ws.df(ws.df(:,colf.acqsrcpair)==2, colf.acc)= ws.df(ws.df(:,colf.acqsrcpair)==2, colf.cho)==1; % C vs N --> C (1)
    ws.df(ws.df(:,colf.acqsrcpair)==3, colf.acc)= ws.df(ws.df(:,colf.acqsrcpair)==3, colf.cho)==1; % C vs I --> C (1)
    ws.df(ws.df(:,colf.acqsrcpair)==4, colf.acc)= ws.df(ws.df(:,colf.acqsrcpair)==4, colf.cho)==3; % D vs N --> N (3)
    ws.df(ws.df(:,colf.acqsrcpair)==5, colf.acc)= ws.df(ws.df(:,colf.acqsrcpair)==5, colf.cho)==4; % D vs I --> I (4)
    ws.df(ws.df(:,colf.acqsrcpair)==6, colf.acc)= nan; % N vs I --> nan (not valid)
    for b=1:length(unique(ws.df(:,1))), ws.df(ws.df(:,colf.testblk)==b,colf.blkacc) =nanmean(ws.df(ws.df(:,colf.testblk)==b,colf.acc) );  end   % Block accuracy: score + implement knock ons 
    if sum(ws.df(:,colf.blkacc) == req.afc_threshold)>0, ws.df(ws.df(:, colf.testblk)> max(ws.df(ws.df(:,colf.blkacc) == req.afc_threshold, colf.testblk)), [colf.cho colf.acc colf.blkacc])=nan;  end % Scores (accuracy, cho) for blocks tt were omitted because subject passed =  nan 
    for b=1:length(unique(ws.df(:,1))) % Calculate AFC scores per block 
        wb.d= ws.df(ws.df(:,colf.testblk)==b,:);  
        
        % Accuracy 
        df_simacc{1}(s, b) =nanmean(wb.d(:, colf.acc));  
        df_simaccnoi{1}(s, b) =nanmean(wb.d(find((wb.d(:, colf.srcpair)==1)+(wb.d(:, colf.srcpair)==2)+(wb.d(:, colf.srcpair)==3)), colf.acc)); % srcpair allocation here refers to analysis-stage src pairs (i.e. in logg.srccomp)
        
        % Overall p(Chose) for each source 
        for sr=1:4   % if you're adding extra questions, add to the rows here   
            if sum(isnan(wb.d(:,colf.cho)))==length(wb.d(:,colf.cho)), 
                df_simpcho{1}{sr,2}(s, b) =nan;  
            else  df_simpcho{1}{sr,2}(s, b) = sum(wb.d(:,colf.cho)==sr)/(3*ws.f1.log.afc.pair_nrep); % Within a set of 6 srcpairs, each source is chooseable 3x
            end
        end 
        
        % Within each pair, which source was chosen ? 
        for c=1:6   
            if sum(isnan(wb.d(:, colf.cho)))==size(wb.d,1), df_simpair_pcho{1}{c,2}(s,b) =  nan; 
            else df_simpair_pcho{1}{c,2}(s,b) =  mean( wb.d(wb.d(:, colf.srcpair)==c, colf.cho) ==  logg.srccomp{c,2}(1));  
            end    
        end
        
        % Did subject pass this block? 
        if sum(isnan(wb.d(:, colf.cho)))==size(wb.d,1),  df_pass{1}(s,b) = nan;
        else df_pass{1}(s,b) =   wb.d(end, colf.blkacc) >= req.afc_threshold; 
        end 
        
        
%         
%         
%         colf
%         wb.d
%         
%         
%         
%         if b==2, er, end
        
%         ws.df = [ws.df ;  sortrows(wb.d,  colf.srcpair)]; 
%         ws.df = [ws.df ;   wb.d]; 
    end   
%     aa=ws.df;
    
    
    for o1=1:1 % Preprocess RTs
    %     if s==1; req.alter{length(req.alter)+1}= 'Random RTs' ; end;  ws.d3(:, colc.chosrcRT)= randi(500,size(ws.d3,1),1); ws.d1(:, coll.rt)= randi(500,size(ws.d1,1),1);  ws.d2(:, coll.rt)= randi(500,size(ws.d2,1),1);  ws.d3(:, colc.chosrcRT)= randi(500,size(ws.d3,1),1); ws.d2(:, [colc.rt1 colc.rt2])= randi(500,size(ws.d3,1),2);  
    if s==1, req.preproc{length(req.preproc)+1,1}='RTs <50ms excluded '; end; ws.d1( ws.d1(:, coll.rt)<50, coll.rt)=nan;  ws.d2( ws.d2(:, colc.rt1)<50, colc.rt1)=nan;  ws.d2( ws.d2(:, colc.chosrcRT)<50, colc.chosrcRT)=nan;   ws.d2( ws.d2(:, colc.rt1)<50, colc.rt1)=nan;  ws.d2( ws.d2(:, colc.rt2)<50, colc.rt2)=nan;  
    if s==1, req.preproc{length(req.preproc)+1,1}='RTs >10000ms excluded '; end;ws.d1( ws.d1(:, coll.rt)>10000, coll.rt)=nan;  ws.d2( ws.d2(:, colc.rt1)>10000, colc.rt1)=nan;  ws.d2( ws.d2(:, colc.chosrcRT)>10000, colc.chosrcRT)=nan;   ws.d2( ws.d2(:, colc.rt1)>10000, colc.rt1)=nan;  ws.d2( ws.d2(:, colc.rt2)>10000, colc.rt2)=nan;   
    %     if s==1, req.preproc{length(req.preproc)+1,1}='RTs mean-centred (within subject)'; end, ws.d1(:, coll.rt)=  ws.d1(:, coll.rt)- nanmean(ws.d1(:, coll.rt));    ws.d2(:, colc.chosrcRT)= ws.d2(:, colc.chosrcRT)- nanmean(ws.d2(:, colc.chosrcRT));     ws.d2(:, colc.rt1)= ws.d2(:, colc.rt1)- nanmean(ws.d2(:, colc.rt1)); ws.d2(:, colc.rt2)= ws.d2(:, colc.rt2)- nanmean(ws.d2(:, colc.rt2));
%     if s==1, req.preproc{length(req.preproc)+1,1}='RTs zscored'; end,  ws.d1(~isnan(ws.d1(:, coll.rt)), coll.rt)= zscore(ws.d1(~isnan(ws.d1(:, coll.rt)), coll.rt));    ws.d2(~isnan(ws.d2(:, colc.rt1)), colc.rt1)= zscore(ws.d2(~isnan(ws.d2(:, colc.rt1)), colc.rt1));    ws.d2(~isnan(ws.d2(:, colc.rt2)), colc.rt2)= zscore(ws.d2(~isnan(ws.d2(:, colc.rt2)), colc.rt2));    ws.d2(~isnan(ws.d2(:, colc.chosrcRT)), colc.chosrcRT)= zscore(ws.d2(~isnan(ws.d2(:, colc.chosrcRT)), colc.chosrcRT));  
    if s==1, req.preproc{length(req.preproc)+1,1}='RTs loggged'; end;  ws.d1(~isnan(ws.d1(:, coll.rt)), coll.rt)= log(ws.d1(~isnan(ws.d1(:, coll.rt)), coll.rt));   ws.d2(~isnan(ws.d2(:, colc.rt1)), colc.rt1)= log(ws.d2(~isnan(ws.d2(:, colc.rt1)), colc.rt1));    ws.d2(~isnan(ws.d2(:, colc.rt2)), colc.rt2)= log(ws.d2(~isnan(ws.d2(:, colc.rt2)), colc.rt2));    ws.d2(~isnan(ws.d2(:, colc.chosrcRT)), colc.chosrcRT)= log(ws.d2(~isnan(ws.d2(:, colc.chosrcRT)), colc.chosrcRT));    
    
     
    end 
    
    % [Meta/misc scores of subject performance ]  ------------------------------------------------------------------------------------------
 
    % Fetch settings  
%     s=1;  ws.f3=  load([where.data logg.subjects{s} fs logg.subjects{s} '_3Rate.mat']);  
    if s==1
        logg.qs_ratesrc = cell(length(fieldnames(ws.f3.log.ratesrc_qs)),4);  ws.vars = fieldnames(ws.f3.log.ratesrc_qs);
        for i=1: length(ws.vars )
            logg.qs_ratesrc{i,1} = ws.vars{i};
            eval(['logg.qs_ratesrc(i,2:end)= ws.f3.log.ratesrc_qs.' ws.vars{i} ';'])
        end
        logg.qs_ratesrc(:,3)=  cellfun(@(x)['1=' x], logg.qs_ratesrc(:,3),'UniformOutput',0); logg.qs_ratesrc(:,4)=  cellfun(@(x)['10=' x], logg.qs_ratesrc(:,4),'UniformOutput',0);
    end

    % Self-rating Qs 
    ws.d3_self = sortrows(ws.d3_self, colrp.q);  d_self(s, 1:length(ws.d3_self(:,1)))= ws.d3_self(:,2);  
    
    % Probabilistic score 
    for o=1:1  % working 
        % let's say: 
        % p(Accurate) =  0.9                             [source's accuracy]
        % p(Agree) = 0.8                                  [likelihood of subject taking the source's advice; 1st choice = irelevant (i think)]
        % 
        % p(Sub Correct)  = p(Sub Agree && Source Accurate)   +   p(Sub Disagree && Source Wrong)   
        % = 0.8*0.9   + 0.2*0.1 
        % = 0.74
        % 
        % Score = p(Sub Correct)*RewardMag + p(Sub wrong)*LossMag  
    end
    if s==1, logg.qs_self{colslf.probscore,1} = 'Probabilistic score'; end   
    for sr=1:4  % Calculate: probabilistic score for Choice session = how much would you win in choice stage, if there had been a ground truth (reflected in the source accuracies)
        wr.acc =  mean(ws.d1(ws.d1(:, coll.source)==sr, coll.srcacc));  
%         if sr==4 , wr.acc = 0.5; end; disp('FORCE I acc = .5');
        wr.cho2agree =  mean(ws.d2(ws.d2(:, colc.chosrc)==sr, colc.cho2agree)); 
        wr.pcorr=  wr.cho2agree*wr.acc + (1- wr.cho2agree)*(1-wr.acc);   ws.srcacc(sr)= wr.acc; 
        % 
        ws.probscore(sr) = wr.pcorr*1 +(1-wr.pcorr)*(-1); wr =[]; 
    end
    d_self(s,colslf.probscore) = sum(ws.probscore);  
    if s==1,logg.qs_ratesrc(end+1,1:4) = {'ProbScore' 'Probabilistic score' 'Very BAD at using experienced src accuracies to max winnings' 'Very GOOD at using experienced src accuracies to max winnings'};  end 
    ws.pscore = nan(4, structmax(colr));   % For convenience, appended to source ratings  
    ws.pscore(:, colr.q)= size(logg.qs_ratesrc,1); 
    ws.pscore(:, colr.src)=1:4;
    ws.pscore(:, colr.rating)=  ws.probscore; 
    ws.f3.ds_data = [ ws.f3.ds_data; ws.pscore];
     
    % Performance on checks   
    if s==1; logg.qs_self([colslf.checklearn colslf.checkchoice colslf.checkall],1)=    {'Learn-Checks', 'Choice-Checks', 'All-Checks'};  end 
    ws.d_ckle =      cell2mat([ws.f1.log.dc_q' ws.f1.log.dc_choice' ws.f1.log.dc_trial']); 
    ws.d_ckcho =    cell2mat([ws.f2.log.dc_q' ws.f2.log.dc_choice' ws.f2.log.dc_trial']); 
    for n=1:2  % Score raw performance 
        eval(['wc.d= ws.d_ck' char(fmat({'le','cho'},n)) ';'])
        eval(['wc.qlist= logg.chk_q.' char(fmat({'learn','choice'},n)) ';'])  
        eval(['wc.triald= ws.d' num2str(n) ';'])
        eval(['wc.col= ' char(fmat({'coll','colc'},n))  ';'])
        wc.d(:, [colck.qtype colck.acc])=  repmat([nan 0], size(wc.d,1),1);  
        if n==1, wc.d=wc.d(wc.d(:, colck.trial)<size(ws.d1,1),:); end   
        
        for o=1:1 % FAKE inputs ########################################
            do.fake =0;
            if do.fake
                disp('fake inputs'); wc.d = [];
                if n==1,
                    %         wc.d(:, colck.q)= ceil(0.5:0.5:12.4);
                    wc.d(:, colck.q)= 1:12;
                    wc.d(:, colck.truefalse)= repmat([1 0]', 6,1);
                    
                else
                    %         wc.d(:, colck.q)= ceil(0.5:0.5:8.4);
                    wc.d(:, colck.q)= 1:8;
                    wc.d(:, colck.truefalse)= 1;
                    wc.d(:, colck.truefalse)= repmat([1 0]', 4,1);
                    
                end
                %         wc.d(:, colck.truefalse)= 1;
                
                tt = 40;   % Hard code what the main-exp trial data is (matching the claims)
                wc.d(:, colck.trial)= 40: 40+size(wc.d,1)-1;
                wc.triald(tt, wc.col.choice2)=1;   tt = tt +1;
                wc.triald(tt, wc.col.choice2)=0;   tt = tt +1;
                wc.triald(tt, wc.col.info)=1;   tt = tt +1;
                wc.triald(tt, wc.col.info)=0;   tt = tt +1;
                wc.triald(tt, wc.col.source)=1;   tt = tt +1;
                wc.triald(tt, wc.col.source)=2;   tt = tt +1;
                wc.triald(tt, wc.col.source)=4;   tt = tt +1;
                wc.triald(tt, wc.col.source)=3;   tt = tt +1;
                wc.triald(tt, wc.col.outcome1)=1;   tt = tt +1;
                wc.triald(tt, wc.col.outcome1)=0;   tt = tt +1;
                wc.triald(tt, wc.col.srcacc)=1;   tt = tt +1;
                wc.triald(tt, wc.col.srcacc)=0;   tt = tt +1;
                
                
                % AGAIN
                %          tt = 40;
                %         wc.triald(tt, wc.col.choice2)=1;   tt = tt +1;
                %         wc.triald(tt, wc.col.choice2)=1;   tt = tt +1;
                %         wc.triald(tt, wc.col.info)=1;   tt = tt +1;
                %         wc.triald(tt, wc.col.info)=1;   tt = tt +1;
                %         wc.triald(tt, wc.col.source)=1;   tt = tt +1;
                %         wc.triald(tt, wc.col.source)=2;   tt = tt +1;
                %         wc.triald(tt, wc.col.source)=2;   tt = tt +1;
                %         wc.triald(tt, wc.col.source)=3;   tt = tt +1;
                %         wc.triald(tt, wc.col.outcome1)=1;   tt = tt +1;
                %         wc.triald(tt, wc.col.outcome1)=1;   tt = tt +1;
                %         wc.triald(tt, wc.col.srcacc)=1;   tt = tt +1;
                %         wc.triald(tt, wc.col.srcacc)=0;   tt = tt +1;
            end
        end
        
        for t=1:size(wc.d,1) 
            wt.td = wc.triald(wc.d(t,colck.trial), :);
            wt.claim = wc.qlist{wc.d(t,colck.q)}; 
            
            % Classify question: % logg.chk_qtype: 1= Own, 2 = Info, 3= Source, 4= SubAcc, 5=SrcAcc 
            if ~isempty(strfind(wt.claim, 'You just guessed')),                         wc.d(t,colck.qtype) = 1;     
            elseif ~isempty(strfind(wt.claim, 'Your final guess was that')),            wc.d(t,colck.qtype) = 1;     
            elseif ~isempty(strfind(wt.claim, 'The source guessed')),                   wc.d(t,colck.qtype) = 2;    
            elseif ~isempty(strfind(wt.claim, 'The source that you just heard from')),  wc.d(t,colck.qtype) = 3;     
            elseif ~isempty(strfind(wt.claim, 'The guess you made was')),               wc.d(t,colck.qtype) = 4;   
            elseif ~isempty(strfind(wt.claim, 'The guess that the source made was')),   wc.d(t,colck.qtype) = 5;    
            % 
            elseif ~isempty(strfind(wt.claim, 'The other player guessed')),                   wc.d(t,colck.qtype) = 2;    
            elseif ~isempty(strfind(wt.claim, 'The other player that you just heard from')),  wc.d(t,colck.qtype) = 3;     
            elseif ~isempty(strfind(wt.claim, 'The guess you made was')),               wc.d(t,colck.qtype) = 4;   
            elseif ~isempty(strfind(wt.claim, 'The guess that the other player made was')),   wc.d(t,colck.qtype) = 5;     
            else disp('UNCLASSIFIED claim: '), disp(wt.claim)
            end
             
            % For debuggg
            wt.qtype = wc.d(t,colck.qtype)  ;    
            wt.tn = t;            
            wt.srcs=  ws.f1.log.srcstim;
            
            % What is the correct value (and in which col), if the claim is TRUE?  
            switch wc.d(t,colck.qtype)  % logg.chk_q.qtype: 1= Own, 2 = Info, 3= Source, 4= SubAcc, 5=SrcAcc 
                case 1, 
                    wc.d(t, colck.td_col) =  wc.col.choice2; wt.whatcol='Subject choice2'; 
                    wc.d(t, colck.td_val) =  length(strfind(wt.claim, 'IS a blap'))>0;  % If claim says 'IS a blap' (phrase is found in text), then the col value col should == 1    
                case 2
                    wc.d(t, colck.td_col) =  wc.col.info;   wt.whatcol='Info (from src)'; 
                    wc.d(t, colck.td_val) =  length(strfind(wt.claim, 'IS a blap'))>0;  % If claim says 'IS a blap' (phrase is found in text), then the col value col should == 1   
                case 3
                    wc.d(t, colck.td_col) =  wc.col.source;   wt.whatcol='Which source'; 
                    
                    % Which src is the claim asserting?
                    wt.claimsrc = lower(fmat({'CAT', 'BIRD','ELEPHANT','FISH','PEACOCK','BUTTERFLY','DOLPHIN','FOX'}, find(cell2mat(cellfun(@(x)~isempty(strfind(wt.claim, x)), {'CAT', 'BIRD','ELEPHANT','FISH','PEACOCK','BUTTERFLY','DOLPHIN','FOX'}, 'UniformOutput',0)))));  if length(wt.claimsrc)~=1, error('WARNING: Something wrong with claim parsing. There should only be 1 source name parsed'); end 
                    wt.notincluded_srcstim =  lower(fmat({'CAT', 'BIRD','ELEPHANT','FISH','PEACOCK','BUTTERFLY','DOLPHIN','FOX'}, find(~cellfun(@(x)sum(strcmp(ws.f1.log.srcstim, lower(x))), {'CAT', 'BIRD','ELEPHANT','FISH','PEACOCK','BUTTERFLY','DOLPHIN','FOX'})))); 
                    wc.d(t, colck.td_val) =  find(strncmp(wt.claimsrc, [ws.f1.log.srcstim wt.notincluded_srcstim], length(wt.claimsrc{1})));  
                case 4 
                    wc.d(t, colck.td_col) =  wc.col.outcome1;  wt.whatcol='Subject choice2 accuracy';  % Only for Learning stage 
                    wc.d(t, colck.td_val) =  length(strfind(wt.claim, 'was CORRECT'))>0  ;  % If claim says 'was CORRECT' (phrase is found in text), then the col value should == 1   
                case 5
                    wc.d(t, colck.td_col) =  wc.col.srcacc;   wt.whatcol='Source info accuracy ';  % Only for Learning stage 
                    wc.d(t, colck.td_val) =  length(strfind(wt.claim, 'was CORRECT'))>0  ;  % If claim says 'was CORRECT' (phrase is found in text), then the col value should == 1     
            end   
            % Look at the main expt (trial) data and check if col + value 
             wt.trialdata_val =  wc.triald(wc.d(t, colck.trial), wc.d(t, colck.td_col));  
             switch wc.d(t, colck.truefalse)
                 case 1, wc.d(t, colck.acc) = wc.d(t, colck.td_val)==wt.trialdata_val; 
                 case 0, wc.d(t, colck.acc) = wc.d(t, colck.td_val)~=wt.trialdata_val; 
             end  
             
%             disp('------------------------------------------------------') 
%             disp(['[tn ' num2str(t) '] Claim:  ' wt.claim]), disp(' ')
%             disp(['       --> Value in col " '     wt.whatcol ' "   should be  ====   '  num2str(wc.d(t, colck.td_val) )])
%             disp(' '),disp(' ')
%             disp(['Response to check item was: '  char(fmat({'Wrong','Correct'}, wc.d(t, colck.acc)+1)) ]),disp(' ') 
%             input('Continue? '); 
            wt=[];
        end 
        d_checks{s,n}=wc.d;  
        if n==1,  
            d_self(s, colslf.checklearn)  = mean(wc.d(:, colck.acc));   ws.chd = wc.d(:, colck.acc); 
        else  
            d_self(s, colslf.checkchoice)  = mean(wc.d(:, colck.acc)); 
            d_self(s, colslf.checkall)  = mean([wc.d(:, colck.acc); ws.chd]);  
        end 
        wc=[];
    end 
     
    % Timing   
    d_time(s,1:2)= f_timejs(ws.f1.log.job.timestamp.start, ws.f1.log.job.timestamp.end);
    d_time(s,3:4)= f_timejs(ws.f2.log.job.timestamp.start, ws.f2.log.job.timestamp.end);
    d_time(s,5:6)= f_timejs(ws.f3.log.job.timestamp.start, ws.f3.log.job.timestamp.end);
    d_time(s,8:9)= f_timejs(ws.f1.log.job.timestamp.start, ws.f3.log.job.timestamp.end); % Overall time    

      
    dr_ratesource{s,1}= ws.f3.ds_data; 
    subjdata{s,1}= logg.subjects{s};
    subjdata{s,2}= ws.d1;
    subjdata{s,3}= ws.d2; 
    ws=[]; 
end

% Quick Debugging
% dl = subjdata{1,2};  dc = subjdata{1,3};    
for sr=1:4
%     sdl=  dl(dl(:, coll.source)==sr,:);
%     sum( sdl(:, coll.srcagree) - (sdl(:, coll.choice)==sdl(:, coll.info)) ) ;
%     mean(sdl(:, coll.srcagree) );
%     
% 
%     sdl=  dc(dc(:, colc.source)==sr,:);
%     sum( sdl(:, colc.srcagree) - (sdl(:, colc.choice1)==sdl(:, colc.info)) ) ;
%      mean(sdl(:, colc.srcagree) );
    
end 

 
% Format data 
for o=1:1  % [ Design checks ]  dck_*: {1} Means {2} Simple fx stats     
    dck_srcacc = {nan(logg.n_subjs,9) [{'COMP' 'SE1Learn h' 'p' 'SE2Choose h' 'p'};[logg.srccomp(:,1) cell(6,4)]]};  
    dck_srcagree= dck_srcacc; dck_randx=  dck_srcacc;   
    dck_agreeXacc={dck_srcacc{1} [{'COMP' 'SE1Learn h' 'p' 'SE2Choose h' 'p'};[logg.srccomp(:,1) cell(6,4)]]; 
	dck_srcacc{1} [{'COMP' 'SE1Learn h' 'p' 'SE2Choose h' 'p'};[logg.srccomp(:,1) cell(6,4)]]};   
    dck_change =  [{nan(logg.n_subjs, 5)} {[{'COMP' 'h' 'p'}; [logg.srccomp(:,1) cell(6,2)]]}];
    dck_subacc{1}=  nan(logg.n_subjs,24); dck_subacc{2}= dck_srcacc{2};
    dck_subyes = dck_subacc;    
     
    for s=1:logg.n_subjs   % Load data 
        ws.c=1;
        for se=1:2 % Sessions 1(Learn) and 2(Choose)
            ws.d =  subjdata{s,se+1};
            for in=1:4  % Source
                ws.i = ws.d(ws.d(:, col.s{se}.source)==in,:); 
                  
                % Calculate quantities here
                if se==1; % Learning session subject beh (Choice stage later)
                    dck_subacc{1}(s, ws.c)=  mean(ws.i(:,col.s{se}.outcome));
                    dck_subyes{1}(s, ws.c)=  mean( ws.i(:,col.s{se}.choice)==1); 
                end    
                dck_srcacc{1}(s, ws.c)=  mean(ws.i(:,   col.s{se}.srcacc));
                dck_randx{1}(s, ws.c) = mean(ws.i(:, col.s{se}.randx));
                dck_srcagree{1}(s, ws.c)= mean( ws.i(:, col.s{se}.info)==ws.i(:, col.s{se}.choice1) );           
                
                % Split by accuracy
                ws.ic=  ws.i(ws.i(:,col.s{se}.outcome)==1,:);
                ws.iw=  ws.i(ws.i(:,col.s{se}.outcome)==0,:);
                dck_agreeXacc{1,1}(s, ws.c)= mean( ws.ic(:, col.s{se}.info)==ws.ic(:, col.s{se}.choice1) );
                dck_agreeXacc{2,1}(s, ws.c)= mean( ws.iw(:, col.s{se}.info)==ws.iw(:, col.s{se}.choice1) );

                %
                ws.c=ws.c+1; if in==4, ws.c=ws.c+1; end
            end
        end
                  
        % Choice session- Subject accuracy +tendencies 
        se=2; ws.d =  subjdata{s,se+1};
        for in=1:4    % Source
            ws.i = ws.d(ws.d(:, col.s{se}.source)==in,:);
            dck_subacc{1}(s, 5+in)=  mean(ws.i(:,colc.outcome1));
            dck_subacc{1}(s, 10+in)=  mean(ws.i(:,colc.outcome2));
            dck_subyes{1}(s,  5+in)=  mean( ws.i(:,col.s{se}.choice1)==1); 
            dck_subyes{1}(s,  10+in)=  mean( ws.i(:,col.s{se}.choice2)==1); 
            dck_change{1}(s, 1+in)= mean( ws.i(:, colc.choice1)~=ws.i(:, colc.choice2));  % Mind changing  
        end 
        dck_change{1}(s, 1)= mean( ws.d(ws.d(:, colc.srcpair)~=0, colc.choice1)~=ws.d(ws.d(:, colc.srcpair)~=0, colc.choice2)); 
        
        % Catch trials
        se=1;  ws.c = 16; dck_subacc{1}(s, ws.c)= mean( subjdata{s,se+1}(subjdata{s,se+1}(:, col.s{se}.source)==0,  col.s{se}.outcome));  % Learning - Catch trials
        ws.c=ws.c+1; se=2;  dck_subacc{1}(s, ws.c)=  mean( subjdata{s,se+1}(subjdata{s,se+1}(:, col.s{se}.src1)==0,  col.s{se}.outcome1));  % Choice - Catch trials
        
%         % Accuracy for Info trials (not split by source)
%         ws.c=ws.c+2; se=1; dck_subacc{1}(s, ws.c)= mean( subjdata{s,se+1}(subjdata{s,se+1}(:, col.s{se}.source)~=0,  col.s{se}.outcome));  % Learning, Info trials (overall) 
%         ws.c=ws.c+1; se=2; dck_subacc{1}(s, ws.c)= mean( subjdata{s,se+1}(subjdata{s,se+1}(:, col.s{se}.sourcepairs)~=0,  col.s{se}.outcome1));  % Choice 1,  info trials (overall) 
%         ws.c=ws.c+1; se=2; dck_subacc{1}(s, ws.c)= mean( subjdata{s,se+1}(subjdata{s,se+1}(:, col.s{se}.sourcepairs)~=0,  col.s{se}.outcome2));% Choice 2, All info trials (overall) 
%         ws.c=ws.c+2; se=2; dck_subacc{1}(s, ws.c)= 0.5+    mean( subjdata{s,se+1}(subjdata{s,se+1}(:, col.s{se}.sourcepairs)~=0,  col.s{se}.outcome2)) -  mean( subjdata{s,se+1}(subjdata{s,se+1}(:, col.s{se}.sourcepairs)~=0,  col.s{se}.outcome1));  % Choice 2>Choice 1 accuracy 
%         ws.c=ws.c+1; se=2; dck_subacc{1}(s, ws.c)= 0.5+    mean( subjdata{s,se+1}(subjdata{s,se+1}(:, col.s{se}.source)~=0 &  subjdata{s,se+1}(:, col.s{se}.source)<3.5,  col.s{se}.outcome2))-mean( subjdata{s,se+1}(subjdata{s,se+1}(:, col.s{se}.source)~=0 &  subjdata{s,se+1}(:, col.s{se}.source)<3.5,  col.s{se}.outcome1)); %  Choice 2>Choice 1 accuracy, C/D/N sources (Added 0.5 to help plotting)
        
        
        
        ws=[]; 
    end
end
for o=1:1  % [ pChoSources ]    d*_: {1} Means: C, D, N, I,[], C-xI, D-xI, N-xI {2} Simple fx {3} Within-pair comparisons  (between subject for rating) session)
    % Session 2: Choosing between sources
    dc_chosrc= {nan(logg.n_subjs,9) nan(logg.n_subjs,6) nan(logg.n_subjs,6)}; dc_infort=dc_chosrc;
    rc_infort= {'Means'  {'ANOVA' [] []}; 'Simple fx' [logg.srccomp(:,1) cell(6,2)]; 'Within Pres Pairs' [logg.srccomp(:,1) cell(6,2)]};  rc_chosrc= {'Means'  {'ANOVA' [] []};  'Simple fx' [logg.srccomp(:,1) cell(6,2)]; 'Within Pres Pairs' [logg.srccomp(:,1) cell(6,2)]; 'Across Pres Pairs' [logg.src_ppcomp(:,1)  cell(4,2)] };
    for s=1:logg.n_subjs   % Load data
        % Assemble datasets
        % subjdata{s,se+1}=sortrows(subjdata{s,se+1}, [colc.srcpair colc.chosrc colc.src2 colc.chosource]);
        
        % #################### Choice session #############################################
        se=2; ws.d{se} = subjdata{s,se+1}(subjdata{s,se+1}(:, col.s{se}.chosource)>0,:); ws.dcdn{se}=  ws.d{se}(find((ws.d{se}(:, col.s{se}.srcpair)==1) + (ws.d{se}(:, col.s{se}.srcpair)==2) + (ws.d{se}(:, col.s{se}.srcpair)==3)),:); % Excluding choice w Inaccurate source        
        for i=1:4, % Source-wise means
            ws.i= ws.d{se}(ws.d{se}(:, col.s{se}.chosource)==i, :);
            ws.icdn= ws.d{se}(ws.dcdn{se}(:, col.s{se}.chosource)==i, :);
            dc_chosrc{1}(s,i)=mean(ws.d{se}(:, col.s{se}.chosource)==i);
            dc_chosrc{1}(s,5+i)=mean(ws.dcdn{se}(:, col.s{se}.chosource)==i);
            dc_infort{1}(s,i)= nanmean( ws.i(:, col.s{se}.chosrcRT));
            dc_infort{1}(s,5+i)= nanmean( ws.icdn(:, col.s{se}.chosrcRT));
        end
        
        for c=1: length(logg.srccomp)  % Compare Info Sources (order: logg.srccomp) 
            ws.cd = ws.d{se}(ws.d{se}(:, col.s{se}.srcpair) ==c,:); 
            ws.cd_cho1 = ws.cd(ws.cd(:, col.s{se}.chosource)==logg.srccomp{c,2}(1),:); 
            ws.cd_cho2 = ws.cd(ws.cd(:, col.s{se}.chosource)==logg.srccomp{c,2}(2),:);  
            dc_chosrc{3}(s,c)= nanmean(ws.cd(:, col.s{se}.chosource)==  logg.srccomp{c,2}(1));
            dc_infort{3}(s,(c-1)*3+1)= nanmean( ws.cd(:, col.s{se}.chosrcRT)  );           % RT - overall
            dc_infort{3}(s,(c-1)*3+2)= nanmean( ws.cd_cho1(:, col.s{se}.chosrcRT)  );      % RT - chose 1
            dc_infort{3}(s,(c-1)*3+3)= nanmean( ws.cd_cho2(:, col.s{se}.chosrcRT)  );      % RT - chose 2
            
            % Simple effects based on means
            dc_chosrc{2}(s,c)=  dc_chosrc{1}(s,logg.srccomp{c,2}(1)) - dc_chosrc{1}(s,logg.srccomp{c,2}(2));
            dc_infort{2}(s,c)=  dc_infort{1}(s,logg.srccomp{c,2}(1)) - dc_infort{1}(s,logg.srccomp{c,2}(2));
        end
        
        ws=[];
    end
end
for o=1:1  % [ Source ratings ] d*_: {q, 1} Means: C, D, N, I {2} Simple fx  
    
    
    % Format data  
    d_ratesource=  repmat([{nan(logg.n_subjs, 4)} {nan(logg.n_subjs, 6)}], size(logg.qs_ratesrc,1),1);  % d_ratesource: row = q, col 1: means score, col 2= simfx. d_ratesource{q,1}: row = subject, col = condition 
    r_ratesource{1}=nan(size(logg.qs_ratesrc,1), 8); r_ratesource{2}=r_ratesource{1}; % {1} h, {2} p. Order: row=q, col= Simple effects, nan, ANOVA
    for s=1:logg.n_subjs
        for q=1:size(logg.qs_ratesrc,1)  % Q
            
            % Source means
            for sr=1:4 
                d_ratesource{q,1}(s,sr) =  dr_ratesource{s}(dr_ratesource{s}(:, colr.q)==q & dr_ratesource{s}(:, colr.src)==sr, colr.rating);
            end
            
            % Simple effects
            for c=1:size(logg.srccomp,1)
                d_ratesource{q,2}(:,c) = d_ratesource{q,1}(:,logg.srccomp{c,2}(1))-  d_ratesource{q,1}(:,logg.srccomp{c,2}(2));
            end
        
        end 
    end  

end 
for o=1:1  % [ Conversion ] 'd*_switch': row=(1) src agree (2) src disagree; col= {1} C, D, N, I,[], C-xI, D-xI, N-xI {2} Simple fx Dis>Agree by src, [], Within Agree/Disagree  {3} Within-pair means 
    
% Behavioural conversion (d_switch): proportion/number of trials 
%   col: {1} C, D, N, I,[], C-xI, D-xI, N-xI {2} Simple fx Dis>Agree by src, [], Within Agree/Disagree  {3} Within-pair means 
%   row: (1) src agree (2) src disagree 
dc_nswitch= repmat({nan(logg.n_subjs, 4*2)   nan(logg.n_subjs, 6)  nan(logg.n_subjs, size(logg.src_ppcomp,1)*3 )}, 2,1);  dc_pswitch=dc_nswitch; 
rc_nswitch =   {'ANOVA (Src x Agr/Dis)' [];  'ANOVA (Agree)' [];  'ANOVA (Disagree)' [];  'Simfx ' [logg.src'; {'AGREE'}; logg.srccomp(:,1);  {'DISAGREE'}; logg.srccomp(:,1)];   'WithinPresPairs ' [{'AGREE'}; logg.srccomp(:,1); {'DISAGREE'}; logg.srccomp(:,1)];     };  rc_pswitch =rc_nswitch ; 
dc_switchntrials  = repmat({nan(logg.n_subjs, size(logg.src_ppcomp,1)*2 )},2,1);   % Pres-Pairs. How many trials in total where subjects chose source X in Y (=prespair) context?

for s=1:logg.n_subjs   % Load data 
    ws.d= subjdata{s,2+1}(subjdata{s,2+1}(:, colc.srcpair)>0,:); % Choice session data
     
    % Source Means
    for i=1:4, % Split by chosen source (i.e. ignoring what the counterfactual source is)
        wi.data= ws.d( ws.d(:, colc.chosource)==i,:);
        wi.agr = wi.data( wi.data(:, colc.srcagree)==1,:);
        wi.dis= wi.data( wi.data(:, colc.srcagree)==0,:);
        wi.data_noi =  wi.data(  (wi.data(:, colc.chosrc)<3.5) &(wi.data(:, colc.src2)<3.5),:);   % Exclude choices against i
        wi.agr_noi  = wi.data_noi( wi.data_noi(:, colc.srcagree)==1,:);
        wi.dis_noi = wi.data_noi( wi.data_noi(:, colc.srcagree)==0,:); 
           
        % Source means
        dc_nswitch{1,1}(s,i) =  sum(  wi.agr(:, colc.choswitch) );
        dc_nswitch{2,1}(s,i) =  sum(  wi.dis(:, colc.choswitch) );
        dc_pswitch{1,1}(s,i) =  mean(  wi.agr(:, colc.choswitch) );
        dc_pswitch{2,1}(s,i) =  mean(  wi.dis(:, colc.choswitch) );
        if i<4
            dc_nswitch{1,1}(s,5+i) =  sum(  wi.agr_noi(:, colc.choswitch) );
            dc_nswitch{2,1}(s,5+i) =  sum(  wi.dis_noi(:, colc.choswitch) );
            dc_pswitch{1,1}(s,5+i) =  mean(  wi.agr_noi(:,colc.choswitch) );
            dc_pswitch{2,1}(s,5+i) =  mean(  wi.dis_noi(:,colc.choswitch) ); 
        end
         
        wi=[];
    end
    
    % Simple effects
    dc_nswitch{1,2}=  dc_nswitch{2,1}(:, 1:4)-dc_nswitch{1,1}(:, 1:4); dc_nswitch{1,2}(:,5)=nan; dc_nswitch{2,2}=dc_nswitch{1,2};  % Agree>Disagree Simple fx, by src
%     dc_pswitch{1,2}=  dc_pswitch{2,1}(:, 1:4)-dc_pswitch{1,1}(:, 1:4); dc_pswitch{1,2}(:, 5)=nan; dc_pswitch{2,2}=dc_pswitch{1,2};
    for c=1: length(logg.srccomp)  % Simple effects, Within agreement/disagreement (order: logg.srccomp)
        for a=1:2
            dc_nswitch{a,2}(s, 5+c)= dc_nswitch{a,1}(s, logg.srccomp{c,2}(1))- dc_nswitch{a,1}(s, logg.srccomp{c,2}(2));
            dc_pswitch{a,2}(s, 5+c)= dc_pswitch{a,1}(s, logg.srccomp{c,2}(1))- dc_pswitch{a,1}(s, logg.srccomp{c,2}(2));
        end
    end
    
    % Within presented pairs 
    for c=1: length(logg.srccomp)  % Compare Info Sources (order: logg.srccomp)
        wc.d = ws.d(ws.d(:, colc.srcpair)==c,:);  
        wc.agr =  wc.d(wc.d(:, colc.srcagree)==1, :);  % Split by source agree/dis
        wc.dis =  wc.d(wc.d(:, colc.srcagree)==0, :); 
        wc.agr_d1= wc.agr(wc.agr(:, colc.chosource)==logg.srccomp{c,2}(1),:);  % Split by what source was chosen, this is some thin baloney slicing here
        wc.agr_d2= wc.agr(wc.agr(:, colc.chosource)==logg.srccomp{c,2}(2),:);
        wc.dis_d1= wc.dis(wc.dis(:, colc.chosource)==logg.srccomp{c,2}(1),:);
        wc.dis_d2= wc.dis(wc.dis(:, colc.chosource)==logg.srccomp{c,2}(2),:);
         
        % N trials 
        dc_switchntrials{1,1}(s, (c-1)*2+1)= size(wc.agr_d1,1); 
        dc_switchntrials{1,1}(s, (c-1)*2+2)= size(wc.agr_d2,1); 
        dc_switchntrials{2,1}(s, (c-1)*2+1)= size(wc.dis_d1,1); 
        dc_switchntrials{2,1}(s, (c-1)*2+2)= size(wc.dis_d2,1);   
        
        % Agreement 
        dc_nswitch{1,3}(s,(c-1)*3+1)=  sum(  wc.agr(:, colc.choice1)~=wc.agr(:, colc.choice2)   ); 
        dc_nswitch{1,3}(s,(c-1)*3+2)=  sum(  wc.agr_d1(:, colc.choice1)~=wc.agr_d1(:, colc.choice2)   ); 
        dc_nswitch{1,3}(s,(c-1)*3+3)=  sum(  wc.agr_d2(:, colc.choice1)~=wc.agr_d2(:, colc.choice2)   ); 
        dc_pswitch{1,3}(s,(c-1)*3+1)=  mean(  wc.agr(:, colc.choice1)~=wc.agr(:, colc.choice2)   ); 
        dc_pswitch{1,3}(s,(c-1)*3+2)=  mean(  wc.agr_d1(:, colc.choice1)~=wc.agr_d1(:, colc.choice2)   ); 
        dc_pswitch{1,3}(s,(c-1)*3+3)=  mean(  wc.agr_d2(:, colc.choice1)~=wc.agr_d2(:, colc.choice2)   );  
        
        % Disagreement 
        dc_nswitch{2,3}(s,(c-1)*3+1)=  sum(  wc.dis(:, colc.choice1)~=wc.dis(:, colc.choice2)   ); 
        dc_nswitch{2,3}(s,(c-1)*3+2)=  sum(  wc.dis_d1(:, colc.choice1)~=wc.dis_d1(:, colc.choice2)   ); 
        dc_nswitch{2,3}(s,(c-1)*3+3)=  sum(  wc.dis_d2(:, colc.choice1)~=wc.dis_d2(:, colc.choice2)   ); 
        dc_pswitch{2,3}(s,(c-1)*3+1)=  mean(  wc.dis(:, colc.choice1)~=wc.dis(:, colc.choice2)   ); 
        dc_pswitch{2,3}(s,(c-1)*3+2)=  mean(  wc.dis_d1(:, colc.choice1)~=wc.dis_d1(:, colc.choice2)   ); 
        dc_pswitch{2,3}(s,(c-1)*3+3)=  mean(  wc.dis_d2(:, colc.choice1)~=wc.dis_d2(:, colc.choice2)   );  
        
        wc=[];
    end
    
    ws=[];
end 
    
end
for o=1:1 % [ Misc admin ] 
    do.this = 0;
    if do.this
        d_time(:,[7 10 14])=nan;
        d_time(:, 11:13) = d_time(:,[1 3 5])*60 + d_time(:,[2 4 6]);  % Session length, in minutes
        d_time(:, 15) = d_time(:,8)*60 + d_time(:,9);    % Overall length, in minutes
        
        close all, figure
        subplot(1,2,1); barwitherr(1.96*(std(d_time(:, 11:13))/sqrt(logg.n_subjs)), mean(d_time(:, 11:13)), 'y')
        text(0.2, 6.5, 'Error bars mark 95% CI');
        ylabel('Minutes'), set(gca,'xticklabel',{'Session1','Session2','Session3'})
        subplot(1,2,2); barwitherr(1.96*(std(d_time(:, 15))/sqrt(logg.n_subjs)), mean(d_time(:, 15)), 'y')
        ylabel('Minutes'), title('Overall length of experiment'); xlim([0 2]) 
    end
end
for o = 1:1 % [ AFC ] df*_
    % df_simpcho{1}{sr,3}: Change in rating from block to block 
    for sr=1:4  % df_simpcho{1}{sr,3}(s, block2onwards) 
        df_simpcho{1}{sr,3} =  df_simpcho{1}{sr,2}(:,2:end)-df_simpcho{1}{sr,2}(:,1:end-1); 
    end 
      
    % df_simpcho{2}: Comparing sources, within blocks
    df_simpcho{2} = logg.srccomp(:,1);
    for c= 1:length(logg.srccomp(:,1))   % df_simpcho{2}{comparison,2}(sub, block)
        df_simpcho{2}{c,2} = df_simpcho{1}{logg.srccomp{c,2}(1),2} - df_simpcho{1}{logg.srccomp{c,2}(2),2};
    end  
     
    % df_pass{1}(sub,block): Did the subject pass this block? 
    % df_pass{2}(sub,block): Accum-passed: has this subject passed yet? 
    df_pass{2}=df_pass{1};
    for s=1:logg.n_subjs; df_pass{2}(s,find(df_pass{2}(s,:)==1):end)=1;   end
end

%% Check design stats  (2Learn & 3Choose)
%   Prefix dck_ (check). Order of sources: C, D, N, I

do.checkdesign =0; 
if do.checkdesign  % (Generally) {1}: Means {2}: Simple fx stats   
    for o=1:1  % Analyse + Plots  
        for c=1: length(logg.srccomp)  % Simple effect comparisons (order: logg.srccomp)
            % Session 1
            [dck_srcacc{2}{c+1,2}, dck_srcacc{2}{c+1,3}]= f_ttest( dck_srcacc{1}(:, logg.srccomp{c,2}(1))- dck_srcacc{1}(:, logg.srccomp{c,2}(2)) );
            [dck_srcagree{2}{c+1,2}, dck_srcagree{2}{c+1,3}]= f_ttest( dck_srcagree{1}(:, logg.srccomp{c,2}(1))- dck_srcagree{1}(:, logg.srccomp{c,2}(2)) );
            [dck_agreeXacc{1,2}{c+1,2}, dck_agreeXacc{1,2}{c+1,3}]= f_ttest( dck_agreeXacc{1,1}(:, logg.srccomp{c,2}(1))- dck_agreeXacc{1,1}(:, logg.srccomp{c,2}(2)));
            [dck_agreeXacc{2,2}{c+1,2}, dck_agreeXacc{2,2}{c+1,3}]= f_ttest( dck_agreeXacc{2,1}(:, logg.srccomp{c,2}(1))- dck_agreeXacc{2,1}(:, logg.srccomp{c,2}(2)));
            
            % Session 2
            [dck_srcacc{2}{c+1,4}, dck_srcacc{2}{c+1,5}]=         f_ttest( dck_srcacc{1}(:, 5+logg.srccomp{c,2}(1))- dck_srcacc{1}(:, 5+logg.srccomp{c,2}(2)) );
            [dck_srcagree{2}{c+1,4}, dck_srcagree{2}{c+1,5}]=            f_ttest( dck_srcagree{1}(:, 5+logg.srccomp{c,2}(1))- dck_srcagree{1}(:, 5+logg.srccomp{c,2}(2)) );
            [dck_agreeXacc{1,2}{c+1,4}, dck_agreeXacc{1,2}{c+1,5}]= f_ttest( dck_agreeXacc{1,1}(:, 5+logg.srccomp{c,2}(1))- dck_agreeXacc{1,1}(:, 5+logg.srccomp{c,2}(2)));
            [dck_agreeXacc{2,2}{c+1,4}, dck_agreeXacc{2,2}{c+1,5}]= f_ttest( dck_agreeXacc{2,1}(:, 5+logg.srccomp{c,2}(1))- dck_agreeXacc{2,1}(:, 5+logg.srccomp{c,2}(2)));
            [dck_change{2}{c+1,2}, dck_change{2}{c+1,3}]=  f_ttest( dck_change{1}(:, 1+logg.srccomp{c,2}(1))- dck_change{1}(:, 1+logg.srccomp{c,2}(2)) );
        end
        if  logg.n_subjs>3
            % ANOVAs
            [wf.a1]=teg_repeated_measures_ANOVA(dck_srcacc{1}(:,1:4), 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
            [wf.a2]=teg_repeated_measures_ANOVA(dck_srcacc{1}(:,6:9), 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
            dck_srcacc{2}(size(dck_srcacc{2},1)+1, 1:5)= {'ANOVA' f_sig(wf.a1.R(4)) wf.a1.R(4) f_sig(wf.a2.R(4)+eps) wf.a2.R(4)}; 
            
            
            %
            [wf.a1]=teg_repeated_measures_ANOVA(dck_srcagree{1}(:,1:4), 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
            [wf.a2]=teg_repeated_measures_ANOVA(dck_srcagree{1}(:,6:9), 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
            dck_srcagree{2}(size(dck_srcagree{2},1)+1, 1:5)= {'ANOVA' f_sig(wf.a1.R(4)) wf.a1.R(4) f_sig(wf.a2.R(4)) wf.a2.R(4)};
            %
            [wf.a1]=teg_repeated_measures_ANOVA(dck_agreeXacc{1,1}(:,1:4), 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
            [wf.a2]=teg_repeated_measures_ANOVA(dck_agreeXacc{1,1}(:,6:9), 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
            dck_agreeXacc{1,2}(size(dck_agreeXacc{1,2},1)+1, 1:5)= {'ANOVA' f_sig(wf.a1.R(4)) wf.a1.R(4) f_sig(wf.a2.R(4)) wf.a2.R(4)};
            %
            [wf.a1]=teg_repeated_measures_ANOVA(dck_agreeXacc{2,1}(:,1:4), 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
            [wf.a2]=teg_repeated_measures_ANOVA(dck_agreeXacc{2,1}(:,6:9), 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
            dck_agreeXacc{2,2}(size(dck_agreeXacc{2,2},1)+1, 1:5)= {'ANOVA' f_sig(wf.a1.R(4)) wf.a1.R(4) f_sig(wf.a2.R(4)) wf.a2.R(4)};
            %
            [wf.a1]=teg_repeated_measures_ANOVA(dck_subyes{1}(:,1:4), 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
            dck_subyes{2}(size(dck_agreeXacc{2,2},1)+1, 1:5)= {'ANOVA' f_sig(wf.a1.R(4)) wf.a1.R(4) f_sig(wf.a2.R(4)) wf.a2.R(4)};
        else disp('ANOVAs skipped')
        end
        
        % Manual tests
        disp('CHECKS: manual tests ------------------------------')
        [ws.h, ws.p]=ttest(dck_subacc{1}(:,21)-dck_subacc{1}(:,20));  disp(['Choice session, cho1 vs cho2:    p= '  num2str(ws.p)])
        
        %
        f.plotcols= 2; f.plotrows=5; f.markersize=4;  f.guidecolor=[0.6 0.6 0.6]; f.markercol = [108 199 230]/256;
        f.figwidth= 900; f.figheight=800; f.fontsize=13;f.fontsize_title=25; f.subplot_VerHorz=[0.1 0.1]; f.fig_BotTop=[0.05 0.05]; f.fig_LeftRight=[0.1 0.1]; 
        figure('Name', ['Check design (n=' num2str(logg.n_subjs) ')'], 'Position', [1950 450 f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
        
        % Subject accuracy by source
%         wf.d =   dck_subacc{1}(:,1:14); wf.null=0.5;     % dck_subacc{1}(:,1:14): Learn-C, Learn-D, Learn-N,  Learn-I, [], Cho1-C, Cho1-D, Cho1-N,  Cho1-I, [], Cho2-C, Cho2-D, Cho2-N,  Cho2-I
        wf.d =   dck_subacc{1}(:,1:9); wf.null=0.5;    
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d ,2)+1)*0+0.25, 'color',f.guidecolor), title('Subject Accuracy (Info trials only)', 'FontSize', f.fontsize_title); hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d ,2)+1)*0+0.75, 'color',f.guidecolor), hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d ,2)+1)*0+0.5, 'color', f.guidecolor),   hold on
        barwitherr(std(wf.d )/sqrt(logg.n_subjs),  nanmean(wf.d ), 'y'), hold on,  scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol), xlim([0 size(wf.d ,2)+1]), ylabel('% Accuracy')
        %         set(gca, 'xtick', 1:size(wf.d, 2), 'xticklabel', {'C','D','N','I',' ','C','D','N','I',' ','C','D','N','I'})
        set(gca, 'xtick', 1:size(wf.d,2), 'xticklabel', {'C','D','N','I',' ','cho-C','cho-D','cho-N','cho-I'}), xlabel('                                      Learning session                                             Choice session')
        [tstat, pvals]= f_markfigstat_1samt(wf.d-(wf.d*0+wf.null), 0.1, 'r');  % data, null, marker y-cord, color 
        xlabel('     Learning session            Choice session (Choice 1) ')
        
        k=k+1; 
%         % Overall subject accuracy  
%         wf.d =   dck_subacc{1}(:, 16:end); wf.null=0.5; % 1: Lrn-Catch   2: Cho-Catch 4: Lrn, All-Info  5: Cho1, All-Info 6: Cho2, All Info  7: Cho2>Cho1 8: Cho2>Cho1 (C/D/N)  
%         subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
%         plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d ,2)+1)*0+wf.null, 'color', f.guidecolor), hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d ,2)+1)*0+0.25, 'color', f.guidecolor), hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d ,2)+1)*0+0.75, 'color',f.guidecolor), title('Overall Subject Accuracy', 'FontSize', f.fontsize_title); hold on, 
%         barwitherr(nanstd(wf.d )/sqrt(logg.n_subjs),  nanmean(wf.d ), 'y'), hold on,  scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol), xlim([0 size(wf.d ,2)+1]), ylabel('% Accurate')
%         set(gca, 'xtick', 1:size(wf.d, 2), 'xticklabel', {'Lrn','Cho', ' ', 'Lrn', 'Cho1', 'Cho2', ' ','C/D/N/I',  '     C/D/N' }) 
%         [tstat, pvals]= f_markfigstat_1samt(wf.d-(wf.d*0+wf.null), 0.1, 'r');  % data, null, marker y-cord, color 
%         xlabel('---------
        
        % Source accuracy
        wf.d= dck_srcacc{1};  wf.null=0.5; 
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+wf.null, 'color',f.guidecolor), title('Source accuracy', 'FontSize', f.fontsize_title), hold on
        barwitherr(std(wf.d)/sqrt(logg.n_subjs),  nanmean(wf.d), 'y'), hold on,  scatter( fvect(repmat(1:size(wf.d,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol), ylabel('% Accuracy') 
        [tstat, pvals]= f_markfigstat_1samt(wf.d-(wf.d*0+wf.null), 0.1, 'r');  % data, null, marker y-cord, color 
        wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( mean(wf.d(:,1:4)) ), 'UniformOutput',0); 
        set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', [wf.xlabel {' ','cho-C','cho-D','cho-N','cho-I'}]),  xlabel('     Learning session            Choice session (Choice 1) ')
         
        % Source Agree
        wf.d= dck_srcagree{1};  wf.null=0.5; 
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+wf.null, 'color',  f.guidecolor), title('Source agreement', 'FontSize', f.fontsize_title), hold on
        barwitherr(std(wf.d)/sqrt(logg.n_subjs),  nanmean(wf.d), 'y'), hold on,  scatter( fvect(repmat(1:size(wf.d,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol), ylabel('% Agree') 
        [tstat, pvals]= f_markfigstat_1samt(wf.d-(wf.d*0+wf.null), 0.1, 'r');  % data, null, marker y-cord, color  
        wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( mean(wf.d(:,1:4)) ), 'UniformOutput',0); 
        set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', [wf.xlabel {' ','cho-C','cho-D','cho-N','cho-I'}]),  xlabel('     Learning session            Choice session (Choice 1) ')
        
%         % Agreement when correct
%         wf.d= dck_agreeXacc{1,1};  wf.null=0.5; 
%         subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
%         plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+wf.null, 'color',f.guidecolor), title('p(Source agree|Choice1 correct)', 'FontSize', f.fontsize_title), hold on
%         barwitherr(nanstd(wf.d)/sqrt(logg.n_subjs),  nanmean(wf.d), 'y'), hold on,  scatter( fvect(repmat(1:size(wf.d,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol) 
%         [tstat, pvals]= f_markfigstat_1samt(wf.d-(wf.d*0+wf.null), 0.1, 'r');  % data, null, marker y-cord, color  
%         wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( mean(wf.d(:,1:4)) ), 'UniformOutput',0);
%         set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', [wf.xlabel {' ','cho-C','cho-D','cho-N','cho-I'}]),  xlabel('     Learning session            Choice session (Choice 1) ') 
%         
%         % Agreement when wrong
%         wf.d= dck_agreeXacc{2,1};  wf.null=0.5; 
%         subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
%         plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+wf.null, 'color', f.guidecolor), title('p(Source agree|Choice1 wrong)', 'FontSize', f.fontsize_title), ylim([0 1]), hold on
%         barwitherr(nanstd(wf.d)/sqrt(logg.n_subjs),  nanmean(wf.d), 'y'), hold on,  scatter( fvect(repmat(1:size(wf.d,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol), ylabel('p(Agree|Wrong)') 
%         [tstat, pvals]= f_markfigstat_1samt(wf.d-(wf.d*0+wf.null), 0.8, 'r');  % data, null, marker y-cord, color 
%         wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( mean(wf.d(:,1:4)) ), 'UniformOutput',0);
%         set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', [wf.xlabel {' ','cho-C','cho-D','cho-N','cho-I'}]),  xlabel('     Learning session            Choice session (Choice 1) ') 
          
        % Agreement when correct
        wf.d=  [dck_agreeXacc{1,1}(:,1:4) nan(logg.n_subjs,1) dck_agreeXacc{2,1}(:,1:4)];  wf.null=0.5; 
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+wf.null, 'color',f.guidecolor), 
        title('p(Source agree|Subject accuracy)', 'FontSize', f.fontsize_title), hold on
        barwitherr(nanstd(wf.d)/sqrt(logg.n_subjs),  nanmean(wf.d), 'y'), hold on,  scatter( fvect(repmat(1:size(wf.d,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol) 
        [tstat, pvals]= f_markfigstat_1samt(wf.d-(wf.d*0+wf.null), 0.1, 'r');  % data, null, marker y-cord, color  
%         wf.xlabel= cellfun(@(x,y) [x '  (' num2str(y,2) ')'] ,  {'C','D','N', 'I'}, num2cell( mean(wf.d(:,1:4)) ), 'UniformOutput',0);
        set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', [ {'C','D','N', 'I', ' ', 'C','D','N', 'I'}]),  
        xlabel('     Subject is correct            Subject is wrong '); ylabel('Source % agreement');
            
 

        k=k+1; 


        % Random number
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        plot(0:1:10, (0:1:10)*0+0.5, 'color',f.guidecolor), title('Random no. ', 'FontSize', f.fontsize_title), hold on
        barwitherr(std(dck_randx{1})/sqrt(logg.n_subjs),  nanmean(dck_randx{1}), 'y'), hold on,  scatter( fvect(repmat(1:size(dck_randx{1},2), logg.n_subjs,1)), dck_randx{1}(:),f.markersize), ylabel('Mean random no.')
        set(gca, 'xtick', 1:size(wf.d,2), 'xticklabel', {'C','D','N','I',' ','cho-C','cho-D','cho-N','cho-I'}), xlabel('     Learning session            Choice session (Choice 1) ') 
        
        % Subject mind-changing 
        wf.d = dck_change{1};  wf.null =0.5;   wf.d= [wf.d(:,1) nan(size(wf.d(:,1))) wf.d(:, 2:end)];  
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+wf.null, 'color', f.guidecolor), hold on
        barwitherr(std(wf.d )/sqrt(logg.n_subjs),  nanmean(wf.d ), 'y');  hold on,  scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol) 
        set(gca, 'xtick', 1:size(wf.d,2), 'xticklabel', [{'Overall' '  ' }  logg.src]), xlim([0 size(wf.d,2)+1]), ylabel('% Change mind'),  title('% Mind changing (Choice session)', 'FontSize', f.fontsize_title);
        [tstat, pvals]= f_markfigstat_1samt(wf.d-(wf.d*0+wf.null), 0.8, 'r');  ylim([0 1]);  % data, null, marker y-cord, color 
        set(gca, 'xticklabel', {'All', ' ','cho-C','cho-D','cho-N','cho-I'}) 
         
        
        % Subject saying yes  
        wf.d =   dck_subyes{1}(:,1:14); wf.null=0.5; 
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d ,2)+1)*0+0.25, 'color', f.guidecolor), title('Subject p(Yes) (Info trials)' , 'FontSize', f.fontsize_title); hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d ,2)+1)*0+0.75, 'color', f.guidecolor), hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d ,2)+1)*0+0.5, 'color', f.guidecolor), hold on
        barwitherr(std(wf.d )/sqrt(logg.n_subjs),  nanmean(wf.d ), 'y'), hold on,  scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol), xlim([0 size(wf.d ,2)+1]), ylabel('p(Yes)')
        set(gca, 'xtick', 1:size(wf.d, 2), 'xticklabel', {'C','D','N','I',' ','C','D','N','I',' ','C','D','N','I',' ','SE2','SE3', ' ', 'SE2', 'SE3ch1', 'SE3ch2'})
        [tstat, pvals]= f_markfigstat_1samt(wf.d-(wf.d*0+wf.null), 0.1, 'r');  % data, null, marker y-cord, color 
        xlabel('  Learning session --------------- (Choice 1) --------------------- Choice 2 ')
          
        %
        wf=[]; 
        
        %
%         disp('Source accuracy X chance?  ----------------------- ')
%         disp('[Learning stage]')
%         disp(['C: ' num2str(f_ttest( dck_srcacc{1}(:,1)- ones(logg.n_subjs,1)*0.5 )) ])
%         disp(['D: ' num2str(f_ttest( dck_srcacc{1}(:,2)- ones(logg.n_subjs,1)*0.5 ))])
%         disp(['N: ' num2str(f_ttest( dck_srcacc{1}(:,3)- ones(logg.n_subjs,1)*0.5 ))])
%         disp(['I: ' num2str(f_ttest( dck_srcacc{1}(:,4)- ones(logg.n_subjs,1)*0.5 ))])
%         disp('[Choice stage]')
%         disp(['C: ' num2str(f_ttest( dck_srcacc{1}(:,5+1)- ones(logg.n_subjs,1)*0.5 ))])
%         disp(['D: ' num2str(f_ttest( dck_srcacc{1}(:,5+2)- ones(logg.n_subjs,1)*0.5 ))])
%         disp(['N: ' num2str(f_ttest( dck_srcacc{1}(:,5+3)- ones(logg.n_subjs,1)*0.5 ))])
%         disp(['I: ' num2str(f_ttest( dck_srcacc{1}(:,5+4)- ones(logg.n_subjs,1)*0.5 ))])
%         disp('Do sources differ in accuracy? ----------------------- ')
%         disp('[Learning stage]')
%         disp(['C vs D: ' num2str(f_ttest( dck_srcacc{1}(:,1)-dck_srcacc{1}(:,2)))  num2str(f_ttest( dck_srcacc{1}(:,1)-dck_srcacc{1}(:,2))) ])
%         disp(['C vs N: ' num2str(f_ttest( dck_srcacc{1}(:,1)-dck_srcacc{1}(:,3)))])
%         disp(['D vs N: ' num2str(f_ttest( dck_srcacc{1}(:,2)-dck_srcacc{1}(:,3)))])
%         disp(['C vs I: ' num2str(f_ttest( dck_srcacc{1}(:,1)-dck_srcacc{1}(:,4))) '   <-- should ==1' ])
%         disp(['D vs I: ' num2str(f_ttest( dck_srcacc{1}(:,2)-dck_srcacc{1}(:,4))) '   <-- should ==1' ])
%         disp(['N vs I: ' num2str(f_ttest( dck_srcacc{1}(:,3)-dck_srcacc{1}(:,4))) '   <-- should ==1' ])
%         disp('[Choice stage]')
%         disp(['C vs D: ' num2str(f_ttest( dck_srcacc{1}(:, 5+1)-dck_srcacc{1}(:, 5+2)))])
%         disp(['C vs N: ' num2str(f_ttest( dck_srcacc{1}(:, 5+1)-dck_srcacc{1}(:, 5+3)))])
%         disp(['D vs N: ' num2str(f_ttest( dck_srcacc{1}(:, 5+2)-dck_srcacc{1}(:, 5+3)))])
%         disp(['C vs I: ' num2str(f_ttest( dck_srcacc{1}(:, 5+1)-dck_srcacc{1}(:, 5+4))) '   <-- should ==1' ])
%         disp(['D vs I: ' num2str(f_ttest( dck_srcacc{1}(:, 5+2)-dck_srcacc{1}(:, 5+4))) '   <-- should ==1' ])
%         disp(['N vs I: ' num2str(f_ttest( dck_srcacc{1}(:, 5+3)-dck_srcacc{1}(:, 5+4))) '   <-- should ==1' ])
%         disp('See dck_srcacc{2} for stats'), openvar dck_srcacc{2}
    end
end

do.afc =0;
if do.afc
    do.afc_plotindiv = 0;
    for o=1:1
        f.plotcols= 3; f.plotrows= 3; f.markersize=3; f.fontsize_title=20; f.fontsize=12;
        f.figwidth= 1000; f.figheight=1000; f.subplot_VerHorz=[0.08 0.07]; f.fig_BotTop=[0.05 0.05]; f.fig_LeftRight=[0.1 0.05]; f.ribbontransparency= 0.4; 
        figure('Name', ['AFC: Overall means (n=' num2str(logg.n_subjs) ')'], 'Position', [150 50 f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
          
% %         % [ Pass threshold ] Accumulative n subjects 
%         wf.d = df_pass{2}; wf.chance = 0.5; wf.ylim = [0 1];
%         %     wf.d = wf.d - repmat(mean(wf.d,2),1, size(wf.d,2)); wf.chance = 0;  wf.ylim =  [-1 1]; % Mean cetre to 0
%         subtightplot(f.plotrows, f.plotcols , k,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k= k+1;
%         plot(1:size(wf.d,2), mean(wf.d), 'LineWidth', 3,'Color',[0.7 0.3 0.3]);   title('Accumulative pass rates','FontSize',f.fontsize_title)
%         xlabel('AFC Block'), ylabel('% Subjects passed'), xlim([1 size(wf.d,2)]), ylim(wf.ylim); set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', 1:size(wf.d,2))
           
        % [ AFC Accuracy] Group mean
        wf.d = df_simacc{1};   wf.chance = 0.5; wf.ylim = [0 1];
        %     wf.d = wf.d - repmat(mean(wf.d,2),1, size(wf.d,2)); wf.chance = 0;  wf.ylim =  [-1 1]; % Mean cetre to 0
        subtightplot(f.plotrows, f.plotcols , k,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k= k+1;
        plot(1:size(wf.d,2),  ones(size(wf.d,2),1)*wf.chance , 'color', [0.8 0.8 0.8]), hold on  % Reference line
        f_plotribbon(wf.d, [0.7 0.1 0.1], f.ribbontransparency); title('2AFC Accuracy','FontSize',f.fontsize_title)
        xlabel('AFC Block'), ylabel('% Accuracy'), xlim([1 size(wf.d,2)]), ylim(wf.ylim); set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', 1:size(wf.d,2))
        hold on; text( 1.1, 0.1, '* N v I pairs excluded entirely (5 pairs only)')
        
         
        % [ AFC Accuracy] Group mean, excluding Inaccurate Source
        wf.d = df_simaccnoi{1};   wf.chance = 0.5; wf.ylim = [0 1];
        %     wf.d = wf.d - repmat(mean(wf.d,2),1, size(wf.d,2)); wf.chance = 0; wf.ylim = [-1 1];  % Mean cetre to 0
        subtightplot(f.plotrows, f.plotcols , k,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k= k+1;
        plot(1:size(wf.d,2),  ones(size(wf.d,2),1)*wf.chance , 'color', [0.8 0.8 0.8]), hold on  % Reference line
        f_plotribbon(wf.d, [0.7 0.1 0.1],f.ribbontransparency); title('2AFC Accuracy (Excl I-Pairs)','FontSize',f.fontsize_title)
        xlabel('AFC Block'), ylabel('% Accuracy'), xlim([1 size(wf.d,2)]), ylim(wf.ylim); set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', 1:size(wf.d,2))
         
        % [ Overall Cho ]
        wf.d= {df_simpcho{1}{1,2}    df_simpcho{1}{2,2}   df_simpcho{1}{3,2}   df_simpcho{1}{4,2}};  wf.chance =1/2; wf.ylim = [0 1.05]; wf.col = {[0.8 0.8 0]; [51/255 1 1];  logg.srccolors{3}; [204/255 0 204/244]};
        subtightplot(f.plotrows, f.plotcols , k,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k= k+1;
        plot(1:size(wf.d{1},2),  ones(size(wf.d,2),1)*wf.chance , 'color', [0.8 0.8 0.8]), hold on  % Reference line
        for sr=1:4;  wf.f{sr} = f_plotribbon(wf.d{sr}, wf.col{sr}, f.ribbontransparency); end ; title('Overall % Chosen','FontSize',f.fontsize_title)
        xlabel('AFC Block'), ylabel('Overall % Chosen'), xlim([1 size(wf.d,2)]), ylim(wf.ylim); set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', 1:size(wf.d,2))
        legend([wf.f{1}.ribbon, wf.f{2}.ribbon, wf.f{3}.ribbon,wf.f{4}.ribbon] , logg.src{1},logg.src{2},logg.src{3},logg.src{4} ) 
        k = ceil((k-1)/f.plotcols)*f.plotcols+1; % New row
          
         
        
        % [ Overall Cho: Simple effects ]
        k = ceil((k-1)/f.plotcols)*f.plotcols+1; % New row 
        for c=1: 3   
            wf.d = df_simpcho{2}{c,2};   wf.chance =0; wf.ylim = [-1 1];
            subtightplot(f.plotrows, f.plotcols , k,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k= k+1;
            plot(1:size(wf.d,2),  ones(size(wf.d,2),1)*wf.chance , 'color', [0.8 0.8 0.8]), hold on  % Reference line
            f_plotribbon(wf.d, [0.1 0.7 0.3], f.ribbontransparency); title(['Overall ' logg.srccomp{c,1}(1) ' > Overall ' logg.srccomp{c,1}(2)],'FontSize',f.fontsize_title)
            xlabel('AFC Block'), ylabel('Difference in Overall Choice '), xlim([1 size(wf.d,2)]), ylim(wf.ylim); set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', 1:size(wf.d,2))
        end 
          
        % [ pCho within pairs ]
        k = ceil((k-1)/f.plotcols)*f.plotcols+1; % New row 
        for c=1: 3   
              wf.d = df_simpair_pcho{1}{c, 2}; wf.chance =0.5; wf.ylim=[0 1];
              subtightplot(f.plotrows, f.plotcols , k,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k= k+1;
              plot(1:size(wf.d,2),  ones(size(wf.d,2),1)*wf.chance , 'color', [0.8 0.8 0.8]), hold on  % Reference line
              f_plotribbon(wf.d, [0.1 0.3 0.7], f.ribbontransparency);  title(['p(Chose ' logg.srccomp{c,1}(1) ') in ' logg.srccomp{c,1}(1) ' vs ' logg.srccomp{c,1}(2)], 'FontSize', f.fontsize_title) 
              xlabel('AFC Block'), ylabel('Mean preference'), xlim([1 size(wf.d,2)]), ylim(wf.ylim); set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', 1:size(wf.d,2))
        end  
        
        % Individual plots
        if do.afc_plotindiv
            do.afc_acc = 0;
            do.afc_overallcho = 1;
            do.afc_pairpref =1;
            w.subspass = logg.subjects(fmat(sortrows([df_pass{2} (1:logg.n_subjs)'], -[4 3 2 1]),  logg.n_subjs*4+1: logg.n_subjs*5)); disp('Subjects in reverse order of passing the AFC:'),  disp(w.subspass)
              
            f.plotcols= 4; f.plotrows= ceil(logg.n_subjs/f.plotcols); f.markersize=3; f.fontsize_title=15; f.fontsize=12;
            f.figwidth= 450; f.figheight=800; f.subplot_VerHorz=[0.05 0.06]; f.fig_BotTop=[0.02 0.08]; f.fig_LeftRight=[0.1 0.05];
            f.titlepos = [0 , 1.3];
            
            if do.afc_acc
                % [ Accuracy]
                wf=[]; wf.d = df_simacc{1};   wf.chance = 0.5; wf.ylim = [0 1.1];
                % wf.d = wf.d - repmat(mean(wf.d,2),1, size(wf.d,2)); wf.chance = 0; wf.ylim = [-1 1]; % Mean cetre to 0
                figure('Name', ['[AFC Indiv Subs] Overall Accuracy (n=' num2str(logg.n_subjs) ')'], 'Position', [100 150 f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
                for s=1:logg.n_subjs    % Individual subjects 
                    subtightplot(f.plotrows, f.plotcols , k,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k= k+1;
                    plot(1:size(wf.d,2),  ones(size(wf.d,2),1)*wf.chance, 'color', [0.8 0.8 0.8]), hold on;   
                    f_plotorscatter(1:size(wf.d,2),  wf.d(s,:),[0.7 0.1 0.1]); title(logg.subjects{s}) 
                    set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', 1:size(wf.d,2)), xlim([1 size(wf.d,2)]), ylim(wf.ylim)
                end
                subtightplot(f.plotrows, f.plotcols , 1,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight);  hold on
                text(f.titlepos(1),f.titlepos(2), '[AFC] Overall accuracy', 'FontSize', f.fontsize_title, 'color', [0.7 0.1 0.1])
                
                % [ Accuracy]
                wf=[]; wf.d = df_simaccnoi{1};   wf.chance = 0.5;  wf.ylim = [0 1.1];
                %  wf.d = wf.d - repmat(mean(wf.d,2),1, size(wf.d,2)); wf.chance = 0; wf.ylim = [-1 1]; % Mean cetre to 0
                figure('Name', ['[AFC Indiv Subs] Overall Accuracy Excl Inaccurate (n=' num2str(logg.n_subjs) ')'], 'Position', [600 150 f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
                for s=1:logg.n_subjs    % Individual subjects
                    subtightplot(f.plotrows, f.plotcols , k,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k= k+1;
                    plot(1:size(wf.d,2),  ones(size(wf.d,2),1)*wf.chance, 'color', [0.8 0.8 0.8]), hold on; 
                    f_plotorscatter(1:size(wf.d,2),  wf.d(s,:),[0.7 0.1 0.1]); title(logg.subjects{s}) 
                    set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', 1:size(wf.d,2)), xlim([1 size(wf.d,2)]), ylim(wf.ylim)
                end
                subtightplot(f.plotrows, f.plotcols , 1,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight);  hold on
                text(f.titlepos(1),f.titlepos(2), '[AFC] Overall accuracy Excl I-Pairs', 'FontSize', f.fontsize_title, 'color', [0.7 0.1 0.1])
            end
            
            if  do.afc_overallcho  
                % [ Overall % Chosen ]
                wf=[]; wf.d= {df_simpcho{1}{1,2}    df_simpcho{1}{2,2}   df_simpcho{1}{3,2}   df_simpcho{1}{4,2}};  wf.chance =1/2; wf.ylim = [-0.1 1.1]; wf.col = {[0.8 0.8 0]; [51/255 1 1];  logg.srccolors{3}; [204/255 0 204/244]};
                figure('Name', ['[AFC Indiv Subs] Overall % Chosen  (n=' num2str(logg.n_subjs) ')'], 'Position', [0 90 f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
                for s=1:logg.n_subjs    % Individual subjects 
                    subtightplot(f.plotrows, f.plotcols , k,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k= k+1;
                    plot(1:size(wf.d{1},2),  ones(size(wf.d,2),1)*wf.chance , 'color', [0.4 0.4 0.4]), hold on  % Reference line
                    for sr=1:4;  
                        wf.f{sr} =  f_plotorscatter((1:size(wf.d{sr},2))+sr*0.02,  wf.d{sr}(s,:),wf.col{sr}); title(logg.subjects{s})  
                    end
                    title(logg.subjects{s}); set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', 1:size(wf.d,2)), xlim([1 size(wf.d,2)]), ylim(wf.ylim)
                    if s==1,  legend([wf.f{1}, wf.f{2}, wf.f{3},wf.f{4}] , logg.src{1},logg.src{2},logg.src{3},logg.src{4} ), end
                end
                subtightplot(f.plotrows, f.plotcols , 1,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight);  hold on
                text(f.titlepos(1),f.titlepos(2), '[AFC] Overall % Chosen', 'FontSize', f.fontsize_title)
                
                % [ Overall Cho: Simple effects ]
                for c=1: 3
                    wf=[]; wf.d = df_simpcho{2}{c,2};   wf.chance =0; wf.ylim = [-1 1];
                    figure('Name', ['[AFC Indiv Subs] Overall Cho: Simple effects (n=' num2str(logg.n_subjs) ')'], 'Position', [50+c*450 90 f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
                   for s=1:logg.n_subjs    % Individual subjects
                        subtightplot(f.plotrows, f.plotcols , k,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k= k+1;
                        plot(1:size(wf.d,2),  ones(size(wf.d,2),1)*wf.chance , 'color', [0.4 0.4 0.4]), hold on  % Reference line
                        f_plotorscatter((1:size(wf.d,2)),  wf.d(s,:),[0.1 0.8 0.1]); title(logg.subjects{s})
                        title(logg.subjects{s}); set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', 1:size(wf.d,2)), xlim([1 size(wf.d,2)]), ylim(wf.ylim)
                   end 
                   subtightplot(f.plotrows, f.plotcols , 1,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight);  hold on
                   text(f.titlepos(1) ,f.titlepos(2) , ['[AFC] Overall ' logg.srccomp{c,1}(1) ' > ' logg.srccomp{c,1}(2)],'FontSize',f.fontsize_title,'color', [0.1 0.7 0.1])
                end  
            end
             
            
            % [ In-pair preference ]
            if  do.afc_pairpref 
                for c=1: 3 
                    wf=[]; wf.d = df_simpair_pcho{1}{c, 2};   wf.chance =0.5; wf.ylim = [-0.1 1.1]; 
                    figure('Name', ['[AFC Indiv Subs] In-pair preferences: (n=' num2str(logg.n_subjs) ')'], 'Position', [150+(c-1)*450 30 f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
                   for s=1:logg.n_subjs    % Individual subjects
                       subtightplot(f.plotrows, f.plotcols , k,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k= k+1;
                       plot(1:size(wf.d,2),  ones(size(wf.d,2),1)*wf.chance , 'color', [0.4 0.4 0.4]), hold on  % Reference line
                       f_plotorscatter((1:size(wf.d,2)),  wf.d(s,:),[0.1 0.1 0.8]); 
                       title(logg.subjects{s}); set(gca,'xtick', 1:size(wf.d,2), 'xticklabel', 1:size(wf.d,2)), xlim([1 size(wf.d,2)]), ylim(wf.ylim)
                   end 
                   subtightplot(f.plotrows, f.plotcols , 1,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight);  hold on
                   text(f.titlepos(1) ,f.titlepos(2) , ['[AFC] Prefer ' logg.srccomp{c,1}(1) ' in ' logg.srccomp{c,1}(1) ' vs ' logg.srccomp{c,1}(2)],'FontSize',f.fontsize_title,'color', [0.1 0.1 0.7])
                end  
            end
        end
    end
end 
  
%% Assess choice/ratings of sources [Choice session3, Rate session4] 
%       Stats printed in prefix r** data structurs 
 
% Choose Source: analysis + plots
do.chosource=0; 
if do.chosource  
    do.chosource_prespairs_flipDN = 1;    % Flip pres-pairs DN pair, so that choosing Neutral is coded as 1 (i.e. compare C>N vs N>D)   
    for o1=1:1 
        if do.chosource_prespairs_flipDN;  disp('ChoSrc: Flipping presented pairs, DN'); 
            dc_chosrc{3}(:, find(strcmp(logg.srccomp(:,1), 'DN')))= 1- dc_chosrc{3}(:, find(strcmp(logg.srccomp(:,1), 'DN'))); 
        
            % Change label in
            rc_chosrc{4,2}(cell2mat(cellfun(@(x)~isempty(strfind(x, 'DN')), rc_chosrc{4,2}(:,1), 'UniformOutput',0)),1) =  cellfun(@(x)strrep(x, 'DN', 'ND'), rc_chosrc{4,2}(cell2mat(cellfun(@(x)~isempty(strfind(x, 'DN')), rc_chosrc{4,2}(:,1), 'UniformOutput',0)),1), 'UniformOutput',0);   % This shouldn't affect the execution of the across-pres-pair test (few lines down below)           
        end  
        
        % ANOVA on means
        [wf.a]=teg_repeated_measures_ANOVA(dc_chosrc{1}(:, 1:4), 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
        rc_chosrc{1,2}(1,2:3)= {f_sig(wf.a.R(4)) wf.a.R(4)};  
        [wf.a]=teg_repeated_measures_ANOVA(dc_infort{1}(:, 1:4), 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
        rc_infort{1,2}(1,2:3)= {f_sig(wf.a.R(4)) wf.a.R(4)};
        for c=1: length(logg.srccomp)  % Comparisons (order: logg.srccomp)
            [rc_chosrc{2,2}{c,2}, rc_chosrc{2, 2}{c,3}, rc_chosrc{2,2}{c,4}]= f_ttest(dc_chosrc{2}(:, c));
            [rc_infort{2,2}{c,2}, rc_infort{2, 2}{c,3}]= f_ttest(dc_infort{2}(:, c));
            
           
            % WITHIN presented pairs
            [rc_chosrc{3,2}{c, 2},  rc_chosrc{3,2}{c, 3}]= f_ttest(dc_chosrc{3}(:,c)-0.5);
            [rc_infort{3,2}{c, 2},  rc_infort{3,2}{c, 3}]=  f_ttest(dc_infort{3}(:,(c-1)*3+2) - dc_infort{3}(:,(c-1)*3+3));  % RTs (rc_infort: mean, choice 1, choice 2)
        end
        for cp=1:size(logg.src_ppcomp,1) % 2nd-order comparison ACROSS presented pairs
            [rc_chosrc{4,2}{cp,2}, rc_chosrc{4,2}{cp,3}]=  f_ttest(dc_chosrc{3}(:, logg.src_ppcomp{cp,2}(1))- dc_chosrc{3}(:, logg.src_ppcomp{cp,2}(2)));
        end
         
        if do.chosource
            f.plotcols= 3; f.plotrows=2;  f.markersize=4; f.fontsize=20;  f.fontsize_title=15; f.markercol = [108 199 230]/256;
            f.figwidth= 900; f.figheight=600; f.fontsize=13;  f.subplot_VerHorz=[0.15 0.1]; f.fig_BotTop=[0.1 0.05]; f.fig_LeftRight=[0.1 0.1];
            figure('Name', ['Session 3: Info Choice results (n=' num2str(logg.n_subjs) ')'], 'Position', [2000 350 f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
            
            % Chosen - overall mean
            wf.d = dc_chosrc{1}(:, 1:4);  wf.null= ones(size(wf.d)).* repmat(0.25, logg.n_subjs,4);
%             wf.d = dc_chosrc{1}(:, 1:end-1);  wf.null= ones(size(wf.d)).* [repmat(0.25, logg.n_subjs,5) repmat(1/3, logg.n_subjs,3)];
            subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
            barwitherr(nanstd(wf.d )/sqrt(logg.n_subjs),  nanmean(wf.d ), 'y'),hold on,  scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol)
            hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+0.25, 'color', 'k'),   % hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+0.33333, 'color', 'k'),
            ylabel('% Chosen','FontSize', f.fontsize), title('Choice of Source','FontSize', f.fontsize_title ); 
%             set(gca, 'xticklabel', {'C','D','N','I',' ','C','D','N','I'},'FontSize', f.fontsize), xlabel('      All                     Excl I ','FontSize', f.fontsize), xlim([0 size(wf.d,2)+1])
            set(gca, 'xticklabel', {'C','D','N','I'},'FontSize', f.fontsize), xlim([0 size(wf.d,2)+1]) 
            [tstat, pvals]= f_markfigstat_1samt(wf.d-wf.null, 0.8, 'r');  % data, null, marker y-cord, color
            
            % Chosen - simple effects comparisons
            wf.d = dc_chosrc{2};  wf.null =0;
            subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
            barwitherr(nanstd(wf.d )/sqrt(logg.n_subjs),  nanmean(wf.d ), 'y');  hold on,  scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol)
            set(gca, 'xtick', 1:size(wf.d,2), 'xticklabel', logg.srccomp(:,1),'FontSize', f.fontsize), xlim([0 size(wf.d,2)+1]), ylabel('% Chose Opt1 > % Chose Opt 2','FontSize', f.fontsize),  title('% Chosen (simple fx)','FontSize', f.fontsize_title );
            [tstat, pvals]= f_markfigstat_1samt(wf.d- wf.null, 0.8, 'r');  ylim([-1 1]);  % data, null, marker y-cord, color
            
            % % Chosen - presented pairs
            wf.d = dc_chosrc{3};   wf.null=0.5;
            subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
            barwitherr(nanstd(wf.d )./sqrt(sum(~isnan(wf.d))),  nanmean(wf.d ), 'y'), hold on,  scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol),
            hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+wf.null, 'color', 'k')
            set(gca, 'xtick', 1:size(wf.d,2), 'xticklabel', logg.srccomp(:,1),'FontSize', f.fontsize), xlim([0 size(wf.d,2)+1]), ylabel('% Chose 1st option','FontSize', f.fontsize),  title('% Chosen (presented pairs)','FontSize', f.fontsize_title ); xlabel('Presented Pair')
            [~, pvals]= f_markfigstat_1samt(wf.d-(wf.d*0+wf.null), 1.1, 'r');  ylim([0 1.2]);  % data, null, marker y-cord, color        
            if do.chosource_prespairs_flipDN;   set(gca, 'xtick', 1:size(wf.d,2), 'xticklabel', cellfun(@(x)strrep(x,'DN', 'ND'), logg.srccomp(:,1), 'UniformOutput',0),'FontSize', f.fontsize); end 
            
            % RTs - overall mean
            wf.d = dc_infort{1}(:, 1:4);   subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
            barwitherr(nanstd(wf.d )./sqrt(sum(~isnan(wf.d))),  nanmean(wf.d ), 'y'), hold on,  scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol)
            ylabel('Mean RT (score)','FontSize', f.fontsize),  title('Source choice RT','FontSize', f.fontsize_title );  
%             set(gca, 'xticklabel', {'C','D','N','I',' ','C','D','N','I'},'FontSize', f.fontsize),  xlabel('      All                     Excl I ','FontSize', f.fontsize), xlim([0 size(wf.d,2)+1])
            set(gca, 'xticklabel', {'C','D','N','I'},'FontSize', f.fontsize) ,xlim([0 size(wf.d,2)+1])
            ylim([7 7.5])
              
            % RT - simple effects comparisons
            wf.d = dc_infort{2}; wf.null=0; subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
            barwitherr(nanstd(wf.d )./sqrt(sum(~isnan(wf.d))),  nanmean(wf.d ), 'y'), hold on,  scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol)
            set(gca, 'xticklabel', logg.srccomp(:,1),'FontSize', f.fontsize), ylabel(sprintf('Mean RT score diff\n (Opt1-Opt2)'),'FontSize', f.fontsize),  title('Info Choice RT (simple fx)','FontSize', f.fontsize_title ), xlim([0 size(wf.d,2)+1])
            [tstat, pvals]= f_markfigstat_1samt(wf.d-wf.null, round( max(wf.d(:))*1.1) , 'r');    % data, null, marker y-cord, color
            
            % RTs - presented pairs
            wf.d = dc_infort{3};   wf.width =0.4;
            subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
            for p=1:size(logg.srccomp,1)
                bar(logg.srccomp{p,3}(1), nanmean(wf.d(:,(p-1)*3+1)),  wf.width, 'facecolor', logg.srccomp{p,4}{1}), hold on  % Overall
                bar(logg.srccomp{p,3}(2), nanmean(wf.d(:,(p-1)*3+2)), wf.width, 'facecolor',  logg.srccomp{p,4}{2}), hold on % Option 1
                bar(logg.srccomp{p,3}(3), nanmean(wf.d(:,(p-1)*3+3)), wf.width, 'facecolor',  logg.srccomp{p,4}{3}), hold on % Option 1
                errorbar(logg.srccomp{p,3}(1), nanmean(wf.d(:,(p-1)*3+1)), nanstd(wf.d(:,(p-1)*3+1))./sqrt(sum(~isnan(wf.d(:,(p-1)*3+1)))), 'color', 'k', 'DisplayName', 'off'), hold on
                errorbar(logg.srccomp{p,3}(2), nanmean(wf.d(:,(p-1)*3+2)), nanstd(wf.d(:,(p-1)*3+2))./sqrt(sum(~isnan(wf.d(:,(p-1)*3+2)))), 'color', 'k', 'DisplayName', 'off'), hold on
                errorbar(logg.srccomp{p,3}(3), nanmean(wf.d(:,(p-1)*3+3)), nanstd(wf.d(:,(p-1)*3+3))./sqrt(sum(~isnan(wf.d(:,(p-1)*3+3)))), 'color', 'k', 'DisplayName', 'off'), hold on
            end 
            set(gca, 'xtick', req.srcomp_xtick, 'xticklabel', logg.srccomp(:,1),'FontSize', f.fontsize), ylabel('Mean RT (score)','FontSize', f.fontsize),  title('Info Choice RT (presented pairs)','FontSize', f.fontsize_title ); xlabel('Presented Pair')
            xlim([min(req.srcomp_xtick)-2.5 max(req.srcomp_xtick)+2.5])
            ylim([5.5 8])
            
            %
            wf=[];
        end
        
        
    end
end 


% Source ratings  
do.ratesource=0;  
if do.ratesource
    for o1=1:1
        do.rateresid = 0;
        if do.rateresid; disp('WARNING: RATINGS ARE DECORRELATED!!!! See code for detail')
            for o2=1:1
                % Get residuals of Y after removing X (Y= target, X = confond)
                wr.yn =  find(strcmp(logg.qs_ratesrc(:,1), 'similar'));
                wr.xn =  find(strcmp(logg.qs_ratesrc(:,1), 'competent'));
                %
                wr.y = d_ratesource{wr.yn,1};  wr.x = d_ratesource{wr.xn,1};
                [ wr.b wr.d wr.st ] = glmfit(wr.x(:), wr.y(:));
                wr.newy= wr.st.resid ;
                wr.newy=  (wr.newy - min(wr.newy))/max(wr.newy - min(wr.newy)); % Rescale residuals to 1
                wr.newy=( wr.newy*max(wr.y(:))-min(wr.y(:))  )+min(wr.y(:));  % Rescale (linear) to original range
                wr.newy= reshape(wr.newy, logg.n_subjs, 4);   % Put back
                
                
                %         for sr=1:4  % Orthogonalize within condition
                %             [ wr.b wr.d wr.st ] = glmfit(wr.x(:,sr), wr.y(:,sr));
                %             wr.newy(:,sr) =  wr.st.resid;
                %         end
                d_ratesource{wr.yn,1} = wr.newy;   % Put back
                for sr=1:6  % Simple effects
                    wr.newyfx(:, sr)=  wr.newy(:, logg.srccomp{sr,2}(1)) - wr.newy(:, logg.srccomp{sr,2}(2));
                end
                d_ratesource{wr.yn,2} = wr.newyfx;
            end
        end
        
        % Show partial
        wh=[
            10 2 6 9 1
            %         4 5 8 3 7
            ];  % All, reordered
        %     wh=[2 1 4 8];  % Similar, competent, like, useful
        
        % wh=[5 3 1 4 2];
        orig.logg.qs_ratesrc = logg.qs_ratesrc;  orig.d_ratesource = d_ratesource; orig.r_ratesource = r_ratesource;
        d_ratesource=d_ratesource(wh,:); logg.qs_ratesrc= logg.qs_ratesrc(wh,:); r_ratesource{1}= r_ratesource{1}(wh,:);  r_ratesource{2}= r_ratesource{2}(wh,:);
        
        f.plotcols= 4; f.plotrows= size(logg.qs_ratesrc,1);    f.markersize=3;   f.fontsize_q=10;  f.fontsize_title=14; f.fontsize=12;   f.figwidth= 1000; f.figheight=1000; f.subplot_VerHorz=[0.06 0.07]; f.fig_BotTop=[0.05 0.05]; f.fig_LeftRight=[0.03 0.02]; f.markercol = [108 199 230]/256;
        figure('Name', ['Explicit ratings: Source traits (n=' num2str(logg.n_subjs) ')'], 'Position', [150 50 f.figwidth f.figheight], 'Color', 'w','number', 'off');
        for q=1: size(logg.qs_ratesrc,1) % Plots + stats
            
            % STATS
            [wq.t wq.p] = f_ttest(d_ratesource{q,2});
            [wq.h wq.p wq.ci wq.st] = ttest(d_ratesource{q,2}); %  wq.st   % <-- Get the statistic
            r_ratesource{1}(q,1:6)= wq.h;
            r_ratesource{2}(q,1:6)= wq.p;
            %         [wf.th, wf.tp]= f_ttest(d_ratesource{q,2});
            %         r_ratesource{2}(q,1:8)=[wf.tp nan wf.a.R(4)];
            [wf.a]=teg_repeated_measures_ANOVA(d_ratesource{q,1}, 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p]
            r_ratesource{3}(q,1:3) = {'ANOVA' num2str( f_sig(wf.a.R(4))) num2str( wf.a.R(4))};
            
            
            % Plots ---------------------------------------------
            k= (q-1)*f.plotcols+1;
            subtightplot(f.plotrows, f.plotcols , k:k+1 ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); axis off
            f.q= logg.qs_ratesrc{q,2}; f.wherenextline=[11 21 31 41 51 61];
            for i=1:length(f.wherenextline)
                if length(strfind(logg.qs_ratesrc{q,2}, ' ') )>f.wherenextline(i)-1,
                    f.q=   [ fmat(f.q, 1:fmat(strfind(f.q, ' '),f.wherenextline(i))) '\n'  fmat(f.q,fmat(strfind(f.q, ' '),f.wherenextline(i))+1:length(f.q))]  ;
                end
            end
            f.t= text(0.1, 0.5, sprintf(f.q),'FontSize',  f.fontsize_q  );   % set(f.t, 'rotation', 15)
            
            
            
            % Ratings - overall means
            wf.d = d_ratesource{q,1};  wf.null=5;   k= (q-1)*f.plotcols+3; wf.scatter_xjitter= (rand(size(wf.d))-0.5)*0.3;
            subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight);
            barwitherr(nanstd(wf.d )/sqrt(logg.n_subjs),  nanmean(wf.d ), 'y'),
            %         hold on,  scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1) + wf.scatter_xjitter), wf.d(:), f.markersize)
            %         hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+ wf.null, 'color', 'k')
            ylabel('Mean rating','FontSize',  f.fontsize), title(['''' logg.qs_ratesrc{q,1} ''''],'FontSize', f.fontsize_title);
            xlim([0 size(wf.d,2)+1]), set(gca, 'xticklabel', {'C','D','N','I'},'FontSize',  f.fontsize)
            %         ylim([0 15])
            
            
            % Ratings - Simple effects
            wf.d = d_ratesource{q,2};  wf.null=0;   k= (q-1)*f.plotcols+4; wf.scatter_xjitter= (rand(size(wf.d))-0.5)*0.3;
            subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight);
            barwitherr(nanstd(wf.d )/sqrt(logg.n_subjs),  nanmean(wf.d ), 'y'), hold on,  scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1) + wf.scatter_xjitter), wf.d(:), f.markersize )
            ylabel('Rating diff','FontSize',  f.fontsize), title([logg.qs_ratesrc{q,1} ' sfx'],'FontSize', f.fontsize_title);
            set(gca, 'xticklabel', logg.srccomp(:,1),'FontSize',  f.fontsize),  xlim([0 7]) %, ylim([-0.7 0.7])
            [tstat, pvals]= f_markfigstat_1samt(wf.d-(wf.d*0+wf.null), -6, 'r');  % data, null, marker y-cord, color
            
            %
            wf=[];
        end
        
        do.ratecorr = 0;     % How do ratings correlate with each other
        if do.ratecorr;  f.plotcols=size(logg.qs_ratesrc,1);  f.plotrows=f.plotcols;     f.markersize=3;   f.fontsize_q=10;  f.fontsize_title=10; f.fontsize=10;   f.figwidth= 1000; f.figheight=1000; f.subplot_VerHorz=[0.06 0.07]; f.fig_BotTop=[0.05 0.05]; f.fig_LeftRight=[0.03 0.02];
            for sr=1:4
                figure('Name', ['Ratings corr: ' logg.src{sr}], 'Position', [150 50 f.figwidth f.figheight], 'Color', 'w','number', 'off');  k=1;
                for q1=1:size(logg.qs_ratesrc,1)
                    for q2=1:size(logg.qs_ratesrc,1)
                        if q2>q1
                            subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1; ws.col=[0 0 0.4];
                            ws.d= [d_ratesource{q1,1}(:,sr) d_ratesource{q2,1}(:,sr)];   ws.dd= ws.d;  ws.d= ws.d(~isnan(sum(ws.d,2)), :);
                            ws.xlabel  = logg.qs_ratesrc{q1};
                            ws.ylabel  = logg.qs_ratesrc{q2};
                            
                            % What kind of correlatiion test?
                            [ws.h1 ws.p1] = kstest(ws.d(:,1)); [ws.h2 ws.p2] = kstest(ws.d(:,2));
                            if ws.p1<0.05 || ws.p2 <0.05; ws.rank_corr=1;
                            else  ws.rank_corr=0;
                            end
                            
                            % Force parametric or nonparametric correlation?
                            %                ws.rank_corr=1; if sr==1 & q ==1, disp('Force nonpar corr'), end
                            ws.rank_corr=0; if sr==1 & q ==1, disp('Force parametric (norm distri) corr'), end
                            %
                            
                            
                            % Stats
                            if ws.rank_corr  % Implement correlation type
                                for v=1:2
                                    [ws.k0,ws.k0,ws.k]=unique(ws.d(:,v));
                                    ws.d(:,v)=(min(ws.k)+ws.k-1);
                                end
                                ws.corrstat ='rs'; ws.ylabel= ['(Rank) ' ws.ylabel];  ws.xlabel= ['(Rank)  ' ws.xlabel];   ws.rank_corr=1;
                                [ws.r ws.p]=  corr(ws.d(:,1), ws.d(:,2),'type','Spearman');
                            else ws.corrstat ='r';   ws.rank_corr=0;
                                [ws.r ws.p]=  corr(ws.d(:,1), ws.d(:,2) );
                            end
                            if ws.p<0.05, ws.pp=  [num2str(ws.p,3) ' *'];  ws.col=[0.9 0 0];
                            elseif ws.p<0.1, ws.pp=  [num2str(ws.p,3) ' t'];  ws.col=[0.7 0 0];
                            else ws.pp=  ' ';
                            end
                            
                            % Scatter
                            scatter(ws.d(:,1), ws.d(:,2),f.markersize, ws.col); hold on, lsline
                            set(gca,'FontSize', f.fontsize), ylabel(sprintf(ws.ylabel),'FontSize', f.fontsize), xlabel(sprintf(ws.xlabel),'FontSize', f.fontsize)
                            if ws.p< 0.1, title([ ws.corrstat  '(' num2str(size(ws.d,1) -1) ')= '  num2str(ws.r,3) ', p='  ws.pp ],'FontSize', f.fontsize_title), end
                            
                            
                            
                            
                            ws=[];
                            
                        else k=k+1;
                        end
                    end
                end
            end
        end
    end
end

%% Conversion of choice in response to info [Session 3]
 % Behavioural conversion (d_switch): proportion/number of trials   
 
do.plotconversion=0;  
 
for o=1:1 % Analysis + plotting  
    rc_nswitch =   {'ANOVA (Src x Agr/Dis)' [];  'ANOVA (Agree)' [];  'ANOVA (Disagree)' [];  'Simfx ' [logg.src'; {'AGREE'}; logg.srccomp(:,1);  {'DISAGREE'}; logg.srccomp(:,1)];   'WithinPresPairs ' [{'AGREE'}; logg.srccomp(:,1); {'DISAGREE'}; logg.srccomp(:,1)];     };  rc_pswitch =rc_nswitch ; 

%     % ANOVAs
    [wf.a]=teg_repeated_measures_ANOVA([dc_pswitch{1,1}(:,1:4) dc_pswitch{2,1}(:,1:4)], [2 4], {'Agreement', 'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
    rc_pswitch{1,2} = [wf.a.labels'   num2cell(cellfun(@(x)f_sig(x),num2cell(wf.a.R(:,4))) )   num2cell(wf.a.R(:, 4))];
    [wf.a]=teg_repeated_measures_ANOVA([dc_pswitch{1,1}(:,1:4)], 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
    rc_pswitch{2,2} = [wf.a.labels'   num2cell(cellfun(@(x)f_sig(x),num2cell(wf.a.R(:,4))) )   num2cell(wf.a.R(:, 4))];
    [wf.a]=teg_repeated_measures_ANOVA([dc_pswitch{2,1}(:,1:4)], 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
    rc_pswitch{3,2} = [wf.a.labels'   num2cell(cellfun(@(x)f_sig(x),num2cell(wf.a.R(:,4))) )   num2cell(wf.a.R(:, 4))];
    [wf.a]=teg_repeated_measures_ANOVA([dc_nswitch{1,1}(:,1:4) dc_nswitch{2,1}(:,1:4)], [2 4], {'Agreement', 'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
%     rc_nswitch{1,2} = [wf.a.labels'   num2cell(cellfun(@(x)f_sig(x),num2cell(wf.a.R(:,4))) )   num2cell(wf.a.R(:, 4))];
    [wf.a]=teg_repeated_measures_ANOVA([dc_nswitch{1,1}(:,1:4)], 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
%     rc_nswitch{2,2} = [wf.a.labels'   num2cell(cellfun(@(x)f_sig(x),num2cell(wf.a.R(:,4))) )   num2cell(wf.a.R(:, 4))];
    [wf.a]=teg_repeated_measures_ANOVA([dc_nswitch{2,1}(:,1:4)], 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
%     rc_nswitch{3,2} = [wf.a.labels'   num2cell(cellfun(@(x)f_sig(x),num2cell(wf.a.R(:,4))) )   num2cell(wf.a.R(:, 4))];
    
   % T-tests 
   [wf.h wf.p]= ttest( [dc_pswitch{2,2}(:, 1:4)-dc_pswitch{1,2}(:, 1:4)   nan(logg.n_subjs,1)   dc_pswitch{1,2}(:, 6:end)    nan(logg.n_subjs,1)   dc_pswitch{2,2}(:, 6:end)]  );
   rc_pswitch{4,2}(:,2:3)= [cellfun(@(x)f_sig(x), num2cell(wf.p), 'UniformOutput',0)' num2cell(wf.p)']; 
   [wf.h wf.p]= ttest( [dc_nswitch{2,2}(:, 1:4)-dc_nswitch{1,2}(:, 1:4)   nan(logg.n_subjs,1)   dc_nswitch{1,2}(:, 6:end)    nan(logg.n_subjs,1)   dc_nswitch{2,2}(:, 6:end)]  );
   rc_nswitch{4,2}(:,2:3)= [cellfun(@(x)f_sig(x), num2cell(wf.p), 'UniformOutput',0)' num2cell(wf.p)']; 
   
   % Presented pairs 
   [wf.h wf.p]= ttest( [ nan(logg.n_subjs,1)     dc_pswitch{1,3}(:, (1:3:6*3)+1)-dc_pswitch{1,3}(:, (1:3:6*3)+2)    nan(logg.n_subjs,1)     dc_pswitch{2,3}(:, (1:3:6*3)+1)-dc_pswitch{2,3}(:, (1:3:6*3)+2)     ]  );
   rc_pswitch{5,2}(:,2:3)= [cellfun(@(x)f_sig(x), num2cell(wf.p), 'UniformOutput',0)' num2cell(wf.p)'];
   [wf.h wf.p]= ttest( [ nan(logg.n_subjs,1)     dc_nswitch{1,3}(:, (1:3:6*3)+1)-dc_nswitch{1,3}(:, (1:3:6*3)+2)    nan(logg.n_subjs,1)     dc_nswitch{2,3}(:, (1:3:6*3)+1)-dc_nswitch{2,3}(:, (1:3:6*3)+2)     ]  );
   rc_nswitch{5,2}(:,2:3)= [cellfun(@(x)f_sig(x), num2cell(wf.p), 'UniformOutput',0)' num2cell(wf.p)'];
    
    
    if do.plotconversion
%         d_plotswitch=  dc_nswitch; disp('[FLAG]  Conversion: plotted no. trials '), f.null= 0; f.null_diff= 0;   f.ylabel='No. trials';
        d_plotswitch=  dc_pswitch; disp('[FLAG]  Conversion: proportion'), f.null= 0.5; f.null_diff= 0;   f.ylabel='proportion';
 
        %
        f.plotcols= 4; f.plotrows=2;  f.markersize=3; f.markercol = [108 199 230]/256;
        f.plotindiv = 1;        
        f.figwidth= 1200; f.figheight=600; f.fontsize=13; f.fontsize_title=15; f.subplot_VerHorz=[0.15 0.08]; f.fig_BotTop=[0.1 0.05]; f.fig_LeftRight=[0.1 0.05];
        figure('Name', ['Behavioural Conversion - ' f.ylabel ' (n=' num2str(logg.n_subjs) ')'], 'Position', [1500 50 f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
        for a=1:2 
             
            % Overall mean  
            wf.d = d_plotswitch{a,1}(:,1:4); wf.null=f.null; wf.marksig_y= str2double(num2str(min(wf.d(:))+ (max(wf.d(:))-min(wf.d(:)))  *0.2,      2)); wf.marksig_y = fmat([0.8 0.2], a);  
            subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
            barwitherr(nanstd(wf.d )./sqrt(sum(~isnan(wf.d))),  nanmean(wf.d ), 'y'), if f.plotindiv , hold on,  scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol), end 
            hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+wf.null, 'color', 'k'),  ylabel(f.ylabel,'FontSize', f.fontsize), title(['p(Switch|Src '  char(fmat({'Agree' 'Disagree'}, a)) ')'],'FontSize', f.fontsize_title);
%             set(gca, 'xticklabel', {'C','D','N','I',' ','C','D','N','I'},'FontSize', f.fontsize),  xlabel('All                     Excl I ','FontSize', f.fontsize), xlim([0 size(wf.d,2)+1])
            set(gca, 'xticklabel', {'C','D','N','I'},'FontSize', f.fontsize),  xlim([0 size(wf.d,2)+1])
            [tstat, pvals]= f_markfigstat_1samt(wf.d- wf.null, wf.marksig_y, 'r');  % data, null, marker y-cord, color
            
            % Simple effects
%             wf.d = d_plotswitch{a,2}; wf.xtick = [{'C','D','N','I',' '} logg.srccomp(:,1)'];
            wf.d = d_plotswitch{a,2}(:,6:end); wf.xtick = logg.srccomp(:,1)';  
            wf.null=f.null_diff;  wf.marksig_y= str2double(num2str(min(wf.d(:))+ (max(wf.d(:))-min(wf.d(:)))  *0.2,      2));
            subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
            barwitherr(nanstd(wf.d)./sqrt(sum(~isnan(wf.d))),  nanmean(wf.d ), 'y'), if f.plotindiv; hold on,  scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol); end
            hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+wf.null, 'color', 'k'),  ylabel(f.ylabel,'FontSize', f.fontsize), title(['Src ' char(fmat({'Agree' 'Disagree'}, a)) ' (Simpfx)'],'FontSize', f.fontsize_title);
            [tstat, pvals]= f_markfigstat_1samt(wf.d- wf.null, wf.marksig_y, 'r');  % data, null, marker y-cord, color
            set(gca, 'xticklabel', wf.xtick,'FontSize', f.fontsize)
%             xlabel(['Disagree > Agree                Comparing Src-' char(fmat({'Agree' 'Disagree'}, a))  ' trials'],'FontSize', f.fontsize)
            xlim([0.3 size(wf.d,2)+0.7])
%             k=k+1; 
             
            % Presented pairs
            wf.d = d_plotswitch{a,3}; wf.null=f.null; wf.width =0.3;  
            subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
            for p=1:size(logg.srccomp,1)
                bar(logg.srccomp{p,3}(1), nanmean(wf.d(:,(p-1)*3+1)),  wf.width, 'facecolor', logg.srccomp{p,4}{1}), hold on  % Overall
                bar(logg.srccomp{p,3}(2), nanmean(wf.d(:,(p-1)*3+2)), wf.width, 'facecolor',  logg.srccomp{p,4}{2}), hold on % Option 1
                bar(logg.srccomp{p,3}(3), nanmean(wf.d(:,(p-1)*3+3)), wf.width, 'facecolor',  logg.srccomp{p,4}{3}), hold on % Option 1
                errorbar(logg.srccomp{p,3}(1), nanmean(wf.d(:,(p-1)*3+1)), nanstd(wf.d(:,(p-1)*3+1))./sqrt(sum(~isnan(wf.d(:,(p-1)*3+1)))), 'color', 'k', 'DisplayName', 'off'), hold on
                errorbar(logg.srccomp{p,3}(2), nanmean(wf.d(:,(p-1)*3+2)), nanstd(wf.d(:,(p-1)*3+2))./sqrt(sum(~isnan(wf.d(:,(p-1)*3+2)))), 'color', 'k', 'DisplayName', 'off'), hold on
                errorbar(logg.srccomp{p,3}(3), nanmean(wf.d(:,(p-1)*3+3)), nanstd(wf.d(:,(p-1)*3+3))./sqrt(sum(~isnan(wf.d(:,(p-1)*3+3)))), 'color', 'k', 'DisplayName', 'off'), hold on
            end
            set(gca, 'xtick', req.srcomp_xtick, 'xticklabel', logg.srccomp(:,1),'FontSize', f.fontsize),
            title(['Src ' char(fmat({'Agree' 'Disagree'}, a)) ' (PresPairs)'],'FontSize', f.fontsize_title); ylabel(f.ylabel,'FontSize', f.fontsize), xlabel('Presented Pair')
            xlim([min(req.srcomp_xtick)-1.5 max(req.srcomp_xtick)+1.5]), ylim auto
             
            % Presented pairs - N trials 
            wf.d = dc_switchntrials{a};  wf.width =0.6;  
            subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;   
            for p=1:size(logg.srccomp,1)
                bar(logg.srccomp{p,3}(1), nanmean(wf.d(:,(p-1)*2+1)),  wf.width, 'facecolor', logg.srccomp{p,4}{2}), hold on % Option 1
                bar(logg.srccomp{p,3}(2), nanmean(wf.d(:,(p-1)*2+2)), wf.width, 'facecolor',  logg.srccomp{p,4}{3}), hold on % Option 2 
                errorbar(logg.srccomp{p,3}(1), nanmean(wf.d(:,(p-1)*2+1)), nanstd(wf.d(:,(p-1)*2+1))./sqrt(sum(~isnan(wf.d(:,(p-1)*2+1)))), 'color', 'k', 'DisplayName', 'off'), hold on
                errorbar(logg.srccomp{p,3}(2), nanmean(wf.d(:,(p-1)*2+2)), nanstd(wf.d(:,(p-1)*2+2))./sqrt(sum(~isnan(wf.d(:,(p-1)*2+2)))), 'color', 'k', 'DisplayName', 'off'), hold on 
            end
            set(gca, 'xtick', linspace(1.5, 14.5, 6), 'xticklabel', logg.srccomp(:,1),'FontSize', f.fontsize), xlim([0  16])
            title(['Src ' char(fmat({'Agree' 'Disagree'}, a)) ' (PresPairs): N Trials'],'FontSize', f.fontsize_title); ylabel('N Trials','FontSize', f.fontsize), xlabel('Presented Pair')
            xlim([3  8])  % CN and DN pairs only
            
            wf=[];  
        end
 
    end
    wf=[];
    %     end
end
 
%% Deeper/Exploratory analysis 

do.costof_avoidD=0;  
if do.costof_avoidD 
    if do.chosource_prespairs_flipDN~=1; error('Turn ChoSrc prespairs_flipDN on!'); end
    
    f.plotcols= 2; f.plotrows=2;  f.markersize=2; f.fontsize=15;  f.fontsize_title=20; f.fontsize_small = 12;
    f.figwidth= 1000; f.figheight=1000; f.subplot_VerHorz=[0.1  0.1]; f.fig_BotTop=[0.1 0.05]; f.fig_LeftRight=[0.1 0.1];
    figure('Name', ['Losing out due to Avoid-D (n=' num2str(logg.n_subjs) ')'], 'Position', [1500 50 f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
    for o1=1:1  % Source choice
        
        % Source preference (in presented pair)
        wf=[]; wf.d =  [dc_chosrc{3}(:,1)      1-dc_chosrc{3}(:,1)   dc_chosrc{3}(:,2)      1-dc_chosrc{3}(:,2)   1-dc_chosrc{3}(:,3)  dc_chosrc{3}(:,3)      dc_chosrc{3}(:,4)      1-dc_chosrc{3}(:,4)      dc_chosrc{3}(:,5)      1-dc_chosrc{3}(:,5)      dc_chosrc{3}(:,6)      1-dc_chosrc{3}(:,6) ];
        wf.null= 0.5; wf.x = [0.6 1.4; 2.6 3.4 ; 4.6 5.4 ; 6.6 7.4 ; 8.6 9.4; 10.6 11.4];   wf.width =0.6;  % Order here depends on do.chosource_prespairs_flipDN ==1
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        for p=1:6
            bar(wf.x(p,1), nanmean(wf.d(:,(p-1)*2+1)), wf.width, 'facecolor',  logg.srccomp{p,4}{2}), hold on % Option 1
            bar(wf.x(p,2), nanmean(wf.d(:,(p-1)*2+2)), wf.width, 'facecolor',  logg.srccomp{p,4}{3}), hold on % Option 1
            errorbar(wf.x(p,1), nanmean(wf.d(:,(p-1)*2+1)), nanstd(wf.d(:,(p-1)*2+1))/sqrt(logg.n_subjs), 'color', 'k', 'DisplayName', 'off'), hold on
            errorbar(wf.x(p,2), nanmean(wf.d(:,(p-1)*2+2)), nanstd(wf.d(:,(p-1)*2+2))/sqrt(logg.n_subjs), 'color', 'k', 'DisplayName', 'off'), hold on
        end
        hold on, plot( wf.x(1)-1:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+ wf.null, 'color', 'k'),  xlim([ wf.x(1)-1  wf.x(end)+1])
        ylabel('% Chosen','FontSize', f.fontsize), title('Source preference (in option pairs)' ,'FontSize', f.fontsize_title );
        set(gca,  'xtick',  mean(wf.x,2), 'xticklabel', {'C   D'; 'C   Nc'; 'D   Nd'; 'C   I'; 'D   I';  'N   I'; },'FontSize', f.fontsize)
        
        % Source preference: DI vs NI head to head
        wf.dd =  [dc_chosrc{3}(:,1)      1-dc_chosrc{3}(:,1)   dc_chosrc{3}(:,2)      1-dc_chosrc{3}(:,2)   1-dc_chosrc{3}(:,3)  dc_chosrc{3}(:,3)      dc_chosrc{3}(:,4)      1-dc_chosrc{3}(:,4)      dc_chosrc{3}(:,5)      1-dc_chosrc{3}(:,5)      dc_chosrc{3}(:,6)      1-dc_chosrc{3}(:,6) ];
        wf.d = wf.dd(:,11) -wf.dd(:,9); wf.null=0; 
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        barwitherr(nanstd(wf.d )/sqrt(logg.n_subjs),  nanmean(wf.d ), 'y'), % hold on,  scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol)
        % hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+0.25, 'color', 'k'),   % hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+0.33333, 'color', 'k'),
        ylabel(sprintf('Difference in p(Source Chosen) directly \nover I (head to head), N > D'),'FontSize', f.fontsize); title('Missed opportunities to gain good quality info','FontSize', f.fontsize_title ); 
        set(gca,'FontSize', f.fontsize,'xtick',[]), xlim([0 size(wf.d,2)+1]) 
        xlabel(sprintf('Proportion of opportunities missed \n(to get good quality info) '), 'FontSize', f.fontsize)
        [wf.t, wf.p]= f_markfigstat_1samt(wf.d-(wf.d*0+wf.null), 0.05, 'r');
        disp('Difference in p(Source Chosen) directly over I (head to head), N > D')
        disp(['     t= '  num2str(wf.t) ', p=' num2str(wf.p,3)]) , disp(' ')
    end
    for o1=1:1  % Conversion
        
        % D > N: Switching when source agrees
        wf=[];  wf.dp  = dc_pswitch{1,2}(:, 6:end); wf.d = wf.dp(:,3);   wf.null = 0;
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        barwitherr(nanstd(wf.d )/sqrt(logg.n_subjs),  nanmean(wf.d ), 'y')
        ylabel(sprintf('D > N difference in\n p(Switch|Source Agrees)'),'FontSize', f.fontsize),
        title('Reactive distancing from D when it Agrees','FontSize', f.fontsize_title );
        set(gca,'FontSize', f.fontsize,'xtick',[]), xlim([0 size(wf.d,2)+1])
        [wf.t , wf.p]= f_markfigstat_1samt(wf.d-(wf.d*0+wf.null), 0.13, 'r');
        xlabel(sprintf('Proportion of times in which subjects were reactive \n in their suspicion/desire to distance themselves\n from D (for no material reason; despite D being\n more likely than them to have been correct)'), 'FontSize', f.fontsize)
        disp('Reactive distancing from D when it Agrees'); disp(['     t= '  num2str(wf.t) ', p=' num2str(wf.p,3)]) , disp(' ')
                
        % D > N: Switching when source disagrees
        wf=[];  wf.dp  = dc_pswitch{2,2}(:, 6:end); wf.d = -wf.dp(:,3);   wf.null = 0;
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        barwitherr(nanstd(wf.d )/sqrt(logg.n_subjs),  nanmean(wf.d ), 'y')
        ylabel(sprintf('D < D difference in\n p(Switch|Source Disagrees)'),'FontSize', f.fontsize),
        title('Disbelief when D Disagrees','FontSize', f.fontsize_title );
        set(gca,'FontSize', f.fontsize,'xtick',[]), xlim([0 size(wf.d,2)+1])
        [wf.t , wf.p]= f_markfigstat_1samt(wf.d-(wf.d*0+wf.null), 0.2, 'r'); 
        xlabel(sprintf('Proportion of times in which subjects refused to \n  follow likely good advice from a source with \n  a better track record than them, solely because that \n source had tended to disagree with them in the past'), 'FontSize', f.fontsize) 
        disp('Disbelief when D Disagrees'); disp(['     t= '  num2str(wf.t) ', p=' num2str(wf.p,3)]) , disp(' ') 
    end
end


% Compare approach-C vs avoid-D
do.compare_AppC_AvD = 0;
if do.compare_AppC_AvD
    if do.chosource_prespairs_flipDN~=1; error('Turn ChoSrc prespairs_flipDN on!'); end
    
    % Plot
    f.plotcols= 4; f.plotrows=2;  f.markersize=2; f.fontsize=15;  f.fontsize_title=15; f.fontsize_small = 12;
    f.plotindiv =1;   f.markercol = [108 112 230]/256;  f.markercol = [0 0 0]/256;
    f.figwidth= 1500; f.figheight=1000; f.subplot_VerHorz=[0.15 0.08]; f.fig_BotTop=[0.1 0.05]; f.fig_LeftRight=[0.1 0.1];
    figure('Name', ['Approach-C vs Avoid-D? (n=' num2str(logg.n_subjs) ')'], 'Position', [1500 50 f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
    r_cnd = cell(0,2);   colslf.BUFFER = structmax(colslf)+1;   % Data (to be used in correlations etc) stored in d_self
    for o1=1:1 % Cho Source (pres pair)
        r_cnd{end+1,1} =  'Source preference'; j=1;
        
        % Source preference (in presented pair)
        wf=[]; wf.d = [dc_chosrc{3}(:,2)      1-dc_chosrc{3}(:,2)   1-dc_chosrc{3}(:,3)  dc_chosrc{3}(:,3)  ];  wf.null= 0.5; wf.x = [0.6 1.4;  2.6 3.4];   wf.width =0.6;  % Order here depends on do.chosource_prespairs_flipDN ==1
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        for p=2:3
            bar(wf.x(p-1,1), nanmean(wf.d(:,(p-2)*2+1)), wf.width, 'facecolor',  logg.srccomp{p,4}{2}), hold on % Option 1
            bar(wf.x(p-1,2), nanmean(wf.d(:,(p-2)*2+2)), wf.width, 'facecolor',  logg.srccomp{p,4}{3}), hold on % Option 1
            errorbar(wf.x(p-1,1), nanmean(wf.d(:,(p-2)*2+1)), nanstd(wf.d(:,(p-2)*2+1))/sqrt(logg.n_subjs), 'color', 'k', 'DisplayName', 'off'), hold on
            errorbar(wf.x(p-1,2), nanmean(wf.d(:,(p-2)*2+2)), nanstd(wf.d(:,(p-2)*2+2))/sqrt(logg.n_subjs), 'color', 'k', 'DisplayName', 'off'), hold on
        end
        if f.plotindiv , hold on;  scatter(repmat( fvect(wf.x'), logg.n_subjs,1), fvect(wf.d'),f.markersize,f.markercol), end
        hold on, plot( wf.x(1)-1:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+ wf.null, 'color', 'k'),  xlim([ wf.x(1)-1  wf.x(end)+1])
        ylabel('% Chosen','FontSize', f.fontsize), title('Source preference (in option pairs)' ,'FontSize', f.fontsize_title );
        set(gca,  'xtick',  mean(wf.x,2), 'xticklabel', {'C   Nc'; 'D   Nd'},'FontSize', f.fontsize), xlabel('C/N pair      D/N pair','FontSize', f.fontsize_small)
        [wf.a]=teg_repeated_measures_ANOVA(wf.d, 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
        r_cnd{end,2}{j,1} = 'ANOVA';  r_cnd{end,2}{j,2}= {f_sig(wf.a.R(4)) wf.a.R(4)};   j=j+1;
        
        % Source preferemce (in presented pair)
        wf=[];  wf.dd = [dc_chosrc{3}(:,2)      1-dc_chosrc{3}(:,2)   1-dc_chosrc{3}(:,3)  dc_chosrc{3}(:,3)  ];   wf.title ={}; wf.d=[]; wf.null= 0;
        wf.d(:,end+1) =  wf.dd(:,1)-wf.dd(:,2);  wf.title{end+1} = '[1]  C > Nc  ';
        wf.d(:,end+1) =  wf.dd(:,4)-wf.dd(:,3);  wf.title{end+1} = '[2]  Nd > D  ';
        wf.d(:,end+1) = (wf.dd(:,1)-wf.dd(:,2)) -  (wf.dd(:,4)-wf.dd(:,3));    wf.title{end+1} = '[1] > [2]  ';
        wf.d(:,end+1) = nan(logg.n_subjs,1);    wf.title{end+1} = ' ';
        wf.d(:,end+1) =  wf.dd(:,1)-wf.dd(:,4);  wf.title{end+1} = 'C > Nd  ';
        wf.d(:,end+1) =  wf.dd(:,3)-wf.dd(:,2);  wf.title{end+1} = 'D > Nc  ';
        wf.d(:,end+1) = nan(logg.n_subjs,1);    wf.title{end+1} = ' ';
        wf.d(:,end+1) =  wf.dd(:,1)-wf.dd(:,3);  wf.title{end+1} = 'C > D  ';
        wf.d(:,end+1) =  wf.dd(:,4)-wf.dd(:,2);  wf.title{end+1} = 'Nd > Nc  ';
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        barwitherr(nanstd(wf.d )/sqrt(logg.n_subjs),  nanmean(wf.d ), 'y'),hold on;
        if f.plotindiv , scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol), end
        hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+ wf.null, 'color', 'k'),
        set(gca, 'xticklabel',  wf.title,'FontSize', f.fontsize_small), xlim([0 size(wf.d,2)+1]),rotateXLabels(gca, 90)
        ylabel('Difference in % Chosen','FontSize', f.fontsize), title(sprintf('Source preference: simple effects\n'),'FontSize', f.fontsize_title );
        [tstat, pvals]= f_markfigstat_1samt(wf.d-wf.null, 0.5, 'r');  % data, null, marker y-cord, color
        text(4.7, -1.5, sprintf('[1] > [2]  \n>0: Approach C\n<0: Avoid D'))
        r_cnd{end,2}{j,1} = 'Simfx'; [r_cnd{end,2}{j,2}(:,1), r_cnd{end,2}{j,2}(:,2)]= f_ttest(wf.d);
        
        colslf.ppchosrc_CmNc =  structmax(colslf)+1;  d_self(:, colslf.ppchosrc_CmNc) =  wf.d(:,1);
        colslf.ppchosrc_NdmD =  structmax(colslf)+1;  d_self(:, colslf.ppchosrc_NdmD) =  wf.d(:,2);
        colslf.ppchosrc_ApC_m_AvD = structmax(colslf)+1;  d_self(:, colslf.ppchosrc_ApC_m_AvD) =  wf.d(:,3); 
    end
    for o1=1:1 % Cho Source RT (pres pair)
        r_cnd{end+1,1} =  'ChoSource RT'; j=1;
        
        % RT Cho Src (in presented pair)
        wf=[]; wf.d = dc_infort{3}(:, [5 6 8 9]);  wf.null= 0; wf.x = [0.6 1.4;  2.6 3.4];   wf.width =0.6;
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        for p=2:3
            bar(wf.x(p-1,1), nanmean(wf.d(:,(p-2)*2+1)), wf.width, 'facecolor',  logg.srccomp{p,4}{2}), hold on % Option 1
            bar(wf.x(p-1,2), nanmean(wf.d(:,(p-2)*2+2)), wf.width, 'facecolor',  logg.srccomp{p,4}{3}), hold on % Option 1
            errorbar(wf.x(p-1,1), nanmean(wf.d(:,(p-2)*2+1)), nanstd(wf.d(:,(p-2)*2+1))./sqrt(sum(~isnan(wf.d(:,(p-2)*2+1)))), 'color', 'k', 'DisplayName', 'off'), hold on
            errorbar(wf.x(p-1,2), nanmean(wf.d(:,(p-2)*2+2)), nanstd(wf.d(:,(p-2)*2+2))./sqrt(sum(~isnan(wf.d(:,(p-2)*2+2)))), 'color', 'k', 'DisplayName', 'off'), hold on
        end
        if f.plotindiv , hold on;  scatter(repmat(fvect(wf.x'), logg.n_subjs,1), fvect(wf.d'),f.markersize,f.markercol), end
        hold on, plot( wf.x(1)-1:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+ wf.null, 'color', 'k'),  xlim([ wf.x(1)-1  wf.x(end)+1])
        ylabel('RT','FontSize', f.fontsize), title('RT Cho Source (in option pairs)' ,'FontSize', f.fontsize_title ); ylim([7 8])
        set(gca,  'xtick',  mean(wf.x,2), 'xticklabel', {'C   Nc'; 'D   Nd'},'FontSize', f.fontsize), xlabel('C/N pair      D/N pair','FontSize', f.fontsize)
        [wf.a]=teg_repeated_measures_ANOVA(wf.d, 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
        r_cnd{end,2}{j,1} = 'ANOVA';  r_cnd{end,2}{j,2}= {f_sig(wf.a.R(4)) wf.a.R(4)};   j=j+1;
        
        % RT Cho Src (in presented pair) : Simple effects
        wf=[];  wf.dd =dc_infort{3}(:, [5 6 8 9]); wf.title ={}; wf.d=[]; wf.null= 0;
        wf.d(:,end+1) =  wf.dd(:,1)-wf.dd(:,2);  wf.title{end+1} = '[1]  C > Nc  ';
        wf.d(:,end+1) =  wf.dd(:,4)-wf.dd(:,3);  wf.title{end+1} = '[2]  Nd > D  ';
        wf.d(:,end+1) = (wf.dd(:,1)-wf.dd(:,2)) -  (wf.dd(:,4)-wf.dd(:,3));    wf.title{end+1} = '[1] > [2]  ';
        wf.d(:,end+1) = nan(logg.n_subjs,1);    wf.title{end+1} = ' ';
        wf.d(:,end+1) =  wf.dd(:,1)-wf.dd(:,4);  wf.title{end+1} = 'C > Nd  ';
        wf.d(:,end+1) =  wf.dd(:,3)-wf.dd(:,2);  wf.title{end+1} = 'D > Nc  ';
        wf.d(:,end+1) = nan(logg.n_subjs,1);    wf.title{end+1} = ' ';
        wf.d(:,end+1) =  wf.dd(:,1)-wf.dd(:,3);  wf.title{end+1} = 'C > D  ';
        wf.d(:,end+1) =  wf.dd(:,4)-wf.dd(:,2);  wf.title{end+1} = 'Nd > Nc  ';    wf.d= - wf.d;  % x = RT speeding
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        barwitherr(nanstd(wf.d )/sqrt(logg.n_subjs),  nanmean(wf.d ), 'y'),hold on;  if f.plotindiv , scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol), end
        hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+ wf.null, 'color', 'k'),
        set(gca, 'xticklabel',  wf.title,'FontSize', f.fontsize_small), xlim([0 size(wf.d,2)+1]),rotateXLabels(gca, 90)
        ylabel('RT speeding','FontSize', f.fontsize), title(sprintf('RT Cho Source (in option pairs): simfx\n'),'FontSize', f.fontsize_title );
        [tstat, pvals]= f_markfigstat_1samt(wf.d-wf.null, 0.5, 'r');  % data, null, marker y-cord, color
        text(4, -0.5, sprintf('>0: Faster for X in \n     X>Y comparison')), ylim([-1 1])
        r_cnd{end,2}{j,1} = 'Simfx'; [r_cnd{end,2}{j,2}(:,1) r_cnd{end,2}{j,2}(:,2)]= f_ttest(wf.d);
    end
    for o1=1:1 % Conversion (pres pair)
        r_cnd{end+1,1} =  'p(Switch|Source Agrees)'; j=1;
        
        % pSwitch when Agree(in presented pair)
        wf=[]; wf.d =dc_pswitch{1,3}(:, [5 6 8 9]);  wf.null= 0.5; wf.x = [0.6 1.4;  2.6 3.4];   wf.width =0.6;
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        for p=2:3
            bar(wf.x(p-1,1), nanmean(wf.d(:,(p-2)*2+1)), wf.width, 'facecolor',  logg.srccomp{p,4}{2}), hold on % Option 1
            bar(wf.x(p-1,2), nanmean(wf.d(:,(p-2)*2+2)), wf.width, 'facecolor',  logg.srccomp{p,4}{3}), hold on % Option 1
            errorbar(wf.x(p-1,1), nanmean(wf.d(:,(p-2)*2+1)), nanstd(wf.d(:,(p-2)*2+1))./sqrt(sum(~isnan(wf.d(:,(p-2)*2+1)))), 'color', 'k', 'DisplayName', 'off'), hold on
            errorbar(wf.x(p-1,2), nanmean(wf.d(:,(p-2)*2+2)), nanstd(wf.d(:,(p-2)*2+2))./sqrt(sum(~isnan(wf.d(:,(p-2)*2+2)))), 'color', 'k', 'DisplayName', 'off'), hold on
        end
        if f.plotindiv , hold on;  scatter(repmat( fvect(wf.x'), logg.n_subjs,1), fvect(wf.d'),f.markersize,f.markercol), end
        hold on, plot( wf.x(1)-1:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+ wf.null, 'color', 'k'),  xlim([ wf.x(1)-1  wf.x(end)+1])
        ylabel('proportion','FontSize', f.fontsize), title(sprintf('p(Switch|Src Agree) \n in option pairs'),'FontSize', f.fontsize_title )
        set(gca,  'xtick',  mean(wf.x,2), 'xticklabel', {'C   Nc'; 'D   Nd'},'FontSize', f.fontsize), xlabel('C/N pair      D/N pair','FontSize', f.fontsize_small)
        [wf.a]=teg_repeated_measures_ANOVA(wf.d, 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
        r_cnd{end,2}{j,1} = 'ANOVA';  r_cnd{end,2}{j,2}= {f_sig(wf.a.R(4)) wf.a.R(4)};   j=j+1;
        
        % pSwitch when Agree(in presented pair) : Simple effects
        wf=[];  wf.dd =dc_pswitch{1,3}(:, [5 6 8 9]); wf.title ={}; wf.d=[]; wf.null= 0;
        wf.d(:,end+1) =  wf.dd(:,4)-wf.dd(:,2);  wf.title{end+1} = 'Nd > Nc  ';
        wf.d(:,end+1) = nan(logg.n_subjs,1);    wf.title{end+1} = ' ';
        wf.d(:,end+1) =  wf.dd(:,1)-wf.dd(:,2);  wf.title{end+1} = '[1]  C > Nc  ';
        wf.d(:,end+1) =  wf.dd(:,4)-wf.dd(:,3);  wf.title{end+1} = '[2]  Nd > D  ';
        wf.d(:,end+1) = (wf.dd(:,1)-wf.dd(:,2)) -  (wf.dd(:,4)-wf.dd(:,3));    wf.title{end+1} = '[1] > [2]  ';
        wf.d(:,end+1) = nan(logg.n_subjs,1);    wf.title{end+1} = ' ';
        wf.d(:,end+1) =  wf.dd(:,1)-wf.dd(:,3);  wf.title{end+1} = 'C > D  ';
        wf.d(:,end+1) =  wf.dd(:,1)-wf.dd(:,4);  wf.title{end+1} = 'C > Nd  ';
        wf.d(:,end+1) =  wf.dd(:,3)-wf.dd(:,2);  wf.title{end+1} = 'D > Nc  ';
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        barwitherr(nanstd(wf.d )./sqrt(sum(~isnan(wf.d))),  nanmean(wf.d ), 'm'),hold on;  if f.plotindiv , scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol), end
        hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+ wf.null, 'color', 'k'),
        set(gca, 'xticklabel',  wf.title,'FontSize', f.fontsize_small), xlim([0 size(wf.d,2)+1]),rotateXLabels(gca, 90), ylim([-1 1]);
        ylabel('proportion','FontSize', f.fontsize), title(sprintf('p(Switch|Src Agree) \n in option pairs (simfx)'),'FontSize', f.fontsize_title );
        [tstat, pvals]= f_markfigstat_1samt(wf.d-wf.null, 0.5, 'r');  % data, null, marker y-cord, color
        text(0.8, -0.7, sprintf('Data only shown for subjects\n  who have >1 trial in the \n  condition-choice bins being \n  compared'))
        r_cnd{end,2}{j,1} = 'Simfx'; [r_cnd{end,2}{j,2}(:,1) r_cnd{end,2}{j,2}(:,2)]= f_ttest(wf.d);
        colslf.pppSwAgr_NdmNc =  structmax(colslf)+1;  d_self(:, colslf.pppSwAgr_NdmNc) =  wf.d(:,1);
        
        
        %
        w.whosub  = ~isnan(wf.d(:,1));  % How many subjects etc
        
        
        % Source disagrees ###################################################
        r_cnd{end+1,1} =  'p(Switch|Source Disagrees)'; j=1;
        
        % pSwitch when Disagree(in presented pair)
        wf=[]; wf.d =dc_pswitch{2,3}(:, [5 6 8 9]);  wf.null= 0.5; wf.x = [0.6 1.4;  2.6 3.4];   wf.width =0.6;
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        for p=2:3
            bar(wf.x(p-1,1), nanmean(wf.d(:,(p-2)*2+1)), wf.width, 'facecolor',  logg.srccomp{p,4}{2}), hold on % Option 1
            bar(wf.x(p-1,2), nanmean(wf.d(:,(p-2)*2+2)), wf.width, 'facecolor',  logg.srccomp{p,4}{3}), hold on % Option 1
            errorbar(wf.x(p-1,1), nanmean(wf.d(:,(p-2)*2+1)), nanstd(wf.d(:,(p-2)*2+1))./sqrt(sum(~isnan(wf.d(:,(p-2)*2+1)))), 'color', 'k', 'DisplayName', 'off'), hold on
            errorbar(wf.x(p-1,2), nanmean(wf.d(:,(p-2)*2+2)), nanstd(wf.d(:,(p-2)*2+2))./sqrt(sum(~isnan(wf.d(:,(p-2)*2+2)))), 'color', 'k', 'DisplayName', 'off'), hold on
        end
        if f.plotindiv , hold on;  scatter(repmat(fvect(wf.x'), logg.n_subjs,1), fvect(wf.d'),f.markersize,f.markercol), end
        hold on, plot( wf.x(1)-1:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+ wf.null, 'color', 'k'),  xlim([ wf.x(1)-1  wf.x(end)+1])
        ylabel('proportion','FontSize', f.fontsize), title(sprintf('p(Switch|Src Disagree) \n in option pairs') ,'FontSize', f.fontsize_title )
        set(gca,  'xtick',  mean(wf.x,2), 'xticklabel', {'C   Nc'; 'D   Nd'},'FontSize', f.fontsize), xlabel('C/N pair      D/N pair','FontSize', f.fontsize_small)
        [wf.a]=teg_repeated_measures_ANOVA(wf.d, 4, {'Source'});  % Row=Task, Choice, TxC; Col=F, df1, df2, p
        r_cnd{end,2}{j,1} = 'ANOVA';  r_cnd{end,2}{j,2}= {f_sig(wf.a.R(4)) wf.a.R(4)};   j=j+1;
        
        % pSwitch when Agree(in presented pair) : Simple effects
        wf=[];  wf.dd =dc_pswitch{2,3}(:, [5 6 8 9]); wf.title ={}; wf.d=[]; wf.null= 0;
        wf.d(:,end+1) =  wf.dd(:,4)-wf.dd(:,2);  wf.title{end+1} = 'Nd > Nc  ';
        wf.d(:,end+1) = nan(logg.n_subjs,1);    wf.title{end+1} = ' ';
        wf.d(:,end+1) =  wf.dd(:,1)-wf.dd(:,2);  wf.title{end+1} = '[1]  C > Nc  ';
        wf.d(:,end+1) =  wf.dd(:,4)-wf.dd(:,3);  wf.title{end+1} = '[2]  Nd > D  ';
        wf.d(:,end+1) = (wf.dd(:,1)-wf.dd(:,2)) -  (wf.dd(:,4)-wf.dd(:,3));    wf.title{end+1} = '[1] > [2]  ';
        wf.d(:,end+1) = nan(logg.n_subjs,1);    wf.title{end+1} = ' ';
        wf.d(:,end+1) =  wf.dd(:,1)-wf.dd(:,3);  wf.title{end+1} = 'C > D  ';
        wf.d(:,end+1) =  wf.dd(:,1)-wf.dd(:,4);  wf.title{end+1} = 'C > Nd  ';
        wf.d(:,end+1) =  wf.dd(:,3)-wf.dd(:,2);  wf.title{end+1} = 'D > Nc  ';
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        barwitherr(nanstd(wf.d )./sqrt(sum(~isnan(wf.d))),  nanmean(wf.d ), 'm'),hold on;  if f.plotindiv , scatter( fvect(repmat(1:size(wf.d ,2), logg.n_subjs,1)), wf.d(:),f.markersize,f.markercol), end
        hold on, plot(0:1:size(wf.d,2)+1, (0:1:size(wf.d,2)+1)*0+ wf.null, 'color', 'k'),
        set(gca, 'xticklabel',  wf.title,'FontSize', f.fontsize_small), xlim([0 size(wf.d,2)+1]),rotateXLabels(gca, 90), ylim([-1 1]);
        ylabel('proportion','FontSize', f.fontsize), title(sprintf('p(Switch|Src Disagree) \n in option pairs (simfx)'),'FontSize', f.fontsize_title );
        [tstat, pvals]= f_markfigstat_1samt(wf.d-wf.null, 0.5, 'r');  % data, null, marker y-cord, color
        text(0.8, -0.7, sprintf('Data only shown for subjects\n  who have >1 trial in the \n  condition-choice bins being \n  compared'))
        r_cnd{end,2}{j,1} = 'Simfx'; [r_cnd{end,2}{j,2}(:,1) r_cnd{end,2}{j,2}(:,2)]= f_ttest(wf.d);
        colslf.pppSwDis_NdmNc =  structmax(colslf)+1;  d_self(:, colslf.pppSwDis_NdmNc) =  wf.d(:,1);
    end  
end
 
%% Correlations   
 
close all

% Run correlation of a single score (across all conds) with condition-wise DVs (e.g. overall winnings x C/D/N/I RTs)
do.corr1withall=0;  
if do.corr1withall  % Condition-wise correlatoins  
    for o=1:1
        if exist('d_self_dv')==1, d_self = d_self_dv;   logg.qs_self =  w.logg.qs_self;  else d_self_dv = d_self;  w.logg.qs_self = logg.qs_self ; end   % This allows me to store ad-hoc DV1's in d_self, which implementing requests for d_self
        
        req.corr_type = 2; % 0=Auto, 1= Rank (Non-Parametric), 2= Normal (Parametric)
        
        % DV#1 (split into conditions) ====================================
        req.corr_dv = {   % (1) DV name, (2) DV data variable (columns = C,D,N,I). Each DV here is given its own figure
            % % Group means =======
%                         'p(Switch|Agree)'       dc_pswitch{1,1}(:,1:4);
%                         'p(Switch|Disagree)'    dc_pswitch{2,1}(:,1:4);
                        'p(ChoSource)'          dc_chosrc{1}(:,1:4); 
%                             'Probabilistic score'   d_ratesource{strcmp(logg.qs_ratesrc(:,1), 'ProbScore'), 1}
                            
            %         % % Simple effects =======
%                                 'p(Switch|Agree)'      dc_pswitch{1,2}(:,6:11);
%                                 'p(Switch|Disagree)'   dc_pswitch{2,2}(:,6:11);
%                                 'p(ChoSource)'         dc_chosrc{2};
%                                  'Probabilistic score'   d_ratesource{strcmp(logg.qs_ratesrc(:,1), 'ProbScore'), 2}
                            
            
            % % Single scores =======
%             'Similarity rating C>D'             d_ratesource{find(strcmp(logg.qs_ratesrc(:,1), 'similar')),2}(:,1); 
%             'C+ Source Preference'              d_self_dv(:, colslf.ppchosrc_CmNc) ;
%             'D- Source Preference'              d_self_dv(:, colslf.ppchosrc_NdmD) ;
%             'C+ > D- Source Preference'         d_self_dv(:, colslf.ppchosrc_ApC_m_AvD) ;
%             'p(Switch|Source Agrees), Nd > Nc ' d_self_dv(:, colslf.pppSwAgr_NdmNc) ;
%             'p(Switch|Source Disagrees), Nd > Nc '  d_self_dv(:, colslf.pppSwDis_NdmNc) ;
%                 'Probabilistic score'        d_self_dv(:, colslf.probscore) 
            }; 
        
        % % % DV#2: all the thing sin logg.qs_self ====================================
        % % Add  new scores
        %     colslf.experienced_CmD_agree = structmax(colslf)+1;   logg.qs_self{colslf.experienced_CmD_agree ,1}='Experienced agreement C>D (Choice stage)';   d_self(:, colslf.experienced_CmD_agree) = dck_srcagree{1}(:, 5+1) - dck_srcagree{1}(:, 5+2);
        %     colslf.simrating_CmD = structmax(colslf)+1;     logg.qs_self{colslf.simrating_CmD ,1}='Similarity rating agreement C>D (Choice stage)';   d_self(:, colslf.simrating_CmD) = d_ratesource{find(strcmp(logg.qs_ratesrc(:,1), 'similar')),2}(:,1);
        %     d_self(:, colslf.experienced_CmD_agree) = dck_srcagree{1}(:, 5+1) - dck_srcagree{1}(:, 5+2);
        
        % Only specific individual
        wh = [colslf.task colslf.task_relative colslf.overall  colslf.sourcelearn colslf.probscore];
        wh =colslf.sourcelearn ;
%         wh =[colslf.checkall colslf.checklearn colslf.checkchoice]; 
        %
        %         wh = [colslf.task colslf.sourcelearn colslf.checkall colslf.checklearn colslf.checkchoice];
        %
        %
%         d_self  = d_self(:, wh );  logg.qs_self = logg.qs_self(wh ,:);
        
        % Titles 
        if size(req.corr_dv{1,2},2)==4, f.titles = logg.src;end         % Plot group means
        if size(req.corr_dv{1,2},2)==6, f.titles = logg.srccomp; end     % Plot simple effects
        if size(req.corr_dv{1,2},2)==1, f.titles = {' '}; end     % Plot single  
        
 
        f.plotcols= 1+length(f.titles ); f.plotrows=size(d_self,2); f.markersize=40; f.fontsize_title=10; f.fontsize_q=20; f.fontsize=10;
        f.figwidth= 1400; f.figheight=800; f.subplot_VerHorz=[0.1 0.1]; f.fig_BotTop=[0.05 0.15]; f.fig_LeftRight=[0.01 0.01]; 
        if length(f.titles)==1 ; f.figwidth= 500; f.figheight=800; f.fontsize_q=10; f.fig_LeftRight=[0.0  0.05]; f.subplot_VerHorz=[0.08 0.01]; f.fig_BotTop=[0.08 0.15]; end 
        
        for dv= 1:size(req.corr_dv,1 )
            figure('Name',  ['Corr single score w cond-specific DVs: ' req.corr_dv{dv,1}], 'Position', [100 50+dv*( f.figheight/3) f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
            wd.d = req.corr_dv{dv,2};  
            wd.r  = corrcoef(wd.d,'rows','complete');   % How is this DV correlated across all conditions? (ignore nans)
             
            for q= 1:size(d_self,2)
                subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
                f.q=  logg.qs_self{q,1};
                if length(strfind(f.q, ' ') )>7, f.q=   [ fmat(f.q, 1:fmat(strfind(f.q, ' '),8)) '\n'  fmat(f.q,fmat(strfind(f.q, ' '),8)+1:length(f.q))]  ; end
                if length(strfind(f.q, ' ') )>13,   f.q=   [ fmat(f.q, 1:fmat(strfind(f.q, ' '),14)) '\n'  fmat(f.q,fmat(strfind(f.q, ' '),14)+1:length(f.q))]  ; end
                %            if length(strfind(f.q, ' ') )>15,   f.q=   [ fmat(f.q, 1:fmat(strfind(f.q, ' '),16)) '\n'  fmat(f.q,fmat(strfind(f.q, ' '),16)+1:length(f.q))]  ; end
                if length(strfind(f.q, ' ') )>20,   f.q=   [ fmat(f.q, 1:fmat(strfind(f.q, ' '),21)) '\n'  fmat(f.q,fmat(strfind(f.q, ' '),21)+1:length(f.q))]  ; end
                if length(strfind(f.q, ' ') )>26,   f.q=   [ fmat(f.q, 1:fmat(strfind(f.q, ' '),27)) '\n'  fmat(f.q,fmat(strfind(f.q, ' '),27)+1:length(f.q))]  ; end
                f.t= text(0.3, 0.4, sprintf(f.q),'FontSize',  f.fontsize_q);   set(f.t, 'rotation', 5), axis off
                 
                
                for sr=1: size(wd.d,2)
                    subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1; ws.col=[0 0 0.4];
                    ws.d= [d_self(:,q),  wd.d(:, sr)]; ws.dd= ws.d;
                    ws.d= ws.d(~isnan(sum(ws.d,2)), :);
                    
                    
                    % What kind of correlation test?
                    [ws.h1 ws.p1] = kstest(ws.d(:,1)); [ws.h2 ws.p2] = kstest(ws.d(:,2));
                    if ws.p1<0.05 || ws.p2 <0.05; ws.rank_corr=1;
                    else  ws.rank_corr=0;
                    end 
                    if req.corr_type==1, ws.rank_corr=1; disp('Force RANK corr'),
                    elseif req.corr_type==2, ws.rank_corr=0; disp('Force NORMAL corr (not rank)'),
                    end
                    
                    
                    % Stats
                    if ws.rank_corr  % Implement correlation type
                        for v=1:2
                            [ws.k0,ws.k0,ws.k]=unique(ws.d(:,v));
                            ws.d(:,v)=(min(ws.k)+ws.k-1);
                        end
                        ws.corrstat ='rs'; ws.ylabel= ['(Rank)\n ' req.corr_dv{dv,1}];   ws.rank_corr=1;
                        [ws.r ws.p]=  corr(ws.d(:,1), ws.d(:,2),'type','Spearman');
                    else ws.corrstat ='r'; ws.ylabel= req.corr_dv{dv,1};  
                        [ws.r ws.p]=  corr(ws.d(:,1), ws.d(:,2) );
                    end  
                    if ws.p<0.05, ws.pp=  [num2str(ws.p,3) ' *'];  ws.col=[0.9 0 0];
                    elseif ws.p<0.1, ws.pp=  [num2str(ws.p,3) ' t'];  ws.col=[0.7 0 0];
                    else ws.pp=  ' ';
                    end
                    
                    % Scatter
                    scatter(ws.d(:,1), ws.d(:,2),f.markersize, ws.col); hold on, lsline
                    set(gca,'FontSize', f.fontsize), ylabel(sprintf(ws.ylabel),'FontSize', f.fontsize)
                    if ws.p> 0.1, title(['[' f.titles{sr} ']'] ,'FontSize', f.fontsize_title)
                    else  title(['[' f.titles{sr} '] ' ws.corrstat  '(' num2str(size(ws.d,1) -1) ')= '  num2str(ws.r,3) ', p='  ws.pp ],'FontSize', f.fontsize_title)
                    end
                     
                    title(['[' f.titles{sr} '] ' ws.corrstat  '(' num2str(size(ws.d,1) -1) ')= '  num2str(ws.r,3) ', p='  ws.pp ],'FontSize', f.fontsize_title)
                    
                    
                    % Add x label? 
                    if length(f.titles)==1 & ws.rank_corr==1,   xlabel(['(Rank) ' f.q])  
                    elseif length(f.titles)==1; xlabel(f.q) 
                    end   
                    
                    ws=[];
                end
            end
            wd=[];
        end
        
    end
end

close all
% Run correlations of 2 scores, within each condition-comparison (e.g. C>D ChoRT x C>D Conversion)
do.corrwithincond =1;
if do.corrwithincond   % Condition-wise correlatoins
    for o=1:1
        %     close all    
        req.corr_type = 0; % 0=Auto, 1= Rank (Non-Parametric), 2= Normal (Parametric)
       
        % DV #1:  Each DV here is given its own figure #############################################
        req.corr_dv1 = {   % (1) DV name, (2) DV data variable (columns = C,D,N,I).
            % Group means ============  
            'p(Chose Source)'    	dc_chosrc{1}(:,1:4);
            'p(Switch|Agree)'       dc_pswitch{1,1}(:,1:4);
            'p(Switch|Disagree)'   dc_pswitch{2,1}(:,1:4);   
            'Probabilistic Score'       d_ratesource{strcmp(logg.qs_ratesrc(:,1), 'ProbScore'), 1}
            
%             % Simple effects ============        
%             'p(Chose Source)'       dc_chosrc{2}; 
%             'p(Switch|Agree)'   	dc_pswitch{1,2}(:,6:11);
%             'p(Switch|Disagree)'   dc_pswitch{2,2}(:,6:11)';
%             'Probabilistic Score'       d_ratesource{strcmp(logg.qs_ratesrc(:,1), 'ProbScore'), 2}
              
            % Single Scores  ============         
%             'Similarity C>D'    repmat(d_ratesource{find(strcmp(logg.qs_ratesrc(:,1), 'similar')),2}(:,1),1,6); 
            };
        
        % DV #2:  Each DV here is in its own row  (repeated across figs) #############################################
         wh_ratesrc  = {   % Source ratings 
            'similar';
            'predictable';   'confident'; 
            'competent';   %  'like'; 'trust';   'useful'; 
%             'suspicious';  'opposite'; 
%             'ProbScore';
            };
         whx = cellfun(@(x)find(strcmp(logg.qs_ratesrc(:,1), x)), wh_ratesrc); 
         req.corr_dv2  =  [logg.qs_ratesrc(whx ,1) d_ratesource(whx,fmat([0 0 0 1 0 2], size(req.corr_dv1{1,2},2) ))];    % Source ratings: means or simfx (autoread)
          
        % Manually specify DV2:  (1) DV name, (2) DV data variable (columns = C,D,N,I)
        % req.corr_dv2  = {
        %        'NameOfDV'      dc_chosrc{1}(:,1:4);
        %     };
        
        % Conditions names 
        if size(req.corr_dv1{1,2},2) ~= size(req.corr_dv2{1,2},2); error('DV1 & DV2 != same no. conditions!');  end  
        if size(req.corr_dv1{1,2},2)==6,  req.corr_condnames = logg.srccomp(:,1);    end % Simple fx  
        if size(req.corr_dv1{1,2},2)==4,  req.corr_condnames = logg.src;  end  % Conditions 
         

        f.plotcols= size(req.corr_dv2{1,2},2)+1; f.plotrows=size(req.corr_dv2 ,1); f.markersize=40; f.fontsize_title=10; f.fontsize_q=20; f.fontsize=10; f.figwidth= 1400; f.figheight=1000;
        f.subplot_VerHorz=[0.05 0.05]; f.fig_BotTop=[0.15 0.15]; f.fig_LeftRight=[0.01 0.01];
        for dv= 1:size(req.corr_dv1,1 )
            figure('Name',  ['Within-Comp corrs: ' req.corr_dv1{dv,1}], 'Position', [100 50 f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
            wd.d =  req.corr_dv1{dv,2};
            
            for q= 1:size(req.corr_dv2,1)
                subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
                f.q=  req.corr_dv2{q,1};
                if length(strfind(f.q, ' ') )>7, f.q=   [ fmat(f.q, 1:fmat(strfind(f.q, ' '),8)) '\n'  fmat(f.q,fmat(strfind(f.q, ' '),8)+1:length(f.q))]  ; end
                if length(strfind(f.q, ' ') )>13,   f.q=   [ fmat(f.q, 1:fmat(strfind(f.q, ' '),14)) '\n'  fmat(f.q,fmat(strfind(f.q, ' '),14)+1:length(f.q))]  ; end
                if length(strfind(f.q, ' ') )>15,   f.q=   [ fmat(f.q, 1:fmat(strfind(f.q, ' '),16)) '\n'  fmat(f.q,fmat(strfind(f.q, ' '),16)+1:length(f.q))]  ; end
                if length(strfind(f.q, ' ') )>20,   f.q=   [ fmat(f.q, 1:fmat(strfind(f.q, ' '),21)) '\n'  fmat(f.q,fmat(strfind(f.q, ' '),21)+1:length(f.q))]  ; end
                if length(strfind(f.q, ' ') )>26,   f.q=   [ fmat(f.q, 1:fmat(strfind(f.q, ' '),27)) '\n'  fmat(f.q,fmat(strfind(f.q, ' '),27)+1:length(f.q))]  ; end
                f.t= text(0.2, 0.4, sprintf(f.q),'FontSize',  f.fontsize_q);   set(f.t, 'rotation', 5), axis off
                
                for sr=1:  size(req.corr_dv2{q,2},2)
                    subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1; ws.col=[0 0 0.4];
                    ws.compname = req.corr_condnames{sr};
                     
                    ws.d= [req.corr_dv2{q,2}(:,sr),  wd.d(:, sr)]; % Graph-Row, Graph-Figure
                    ws.dd= ws.d;  ws.d= ws.d(~isnan(sum(ws.d,2)), :);
                    
                    % What kind of correlation test?
                    [ws.h1 ws.p1] = kstest(ws.d(:,1)); [ws.h2 ws.p2] = kstest(ws.d(:,2));
                    if ws.p1<0.05 || ws.p2 <0.05; ws.rank_corr=1;
                    else  ws.rank_corr=0;
                    end
                    if req.corr_type==1, ws.rank_corr=1; disp('Force RANK corr'),
                    elseif req.corr_type==2, ws.rank_corr=0; disp('Force NORMAL corr (not rank)'),
                    end
                    
                    
                    
                    
                    % Stats
                    if ws.rank_corr  % Implement correlation type
                        for v=1:2
                            [ws.k0,ws.k0,ws.k]=unique(ws.d(:,v));
                            ws.d(:,v)=(min(ws.k)+ws.k-1);
                        end
                        ws.corrstat ='rs'; ws.ylabel= ['(Rank)\n ' req.corr_dv1{dv,1}];   ws.rank_corr=1;
                        [ws.r ws.p]=  corr(ws.d(:,1), ws.d(:,2),'type','Spearman');
                    else ws.corrstat ='r'; ws.ylabel= req.corr_dv1{dv,1};  ws.rank_corr=0;
                        [ws.r ws.p]=  corr(ws.d(:,1), ws.d(:,2) );
                    end
                    if ws.p<0.05, ws.pp=  [num2str(ws.p,3) ' *'];  ws.col=[0.9 0 0];
                    elseif ws.p<0.1, ws.pp=  [num2str(ws.p,3) ' t'];  ws.col=[0.7 0 0];
                    else ws.pp=  ' ';
                    end
                    
                    % Scatter
                    scatter(ws.d(:,1), ws.d(:,2),f.markersize, ws.col); hold on, lsline
                    set(gca,'FontSize', f.fontsize), ylabel(sprintf(ws.ylabel),'FontSize', f.fontsize)
                    if ws.p> 0.1, title(['[' ws.compname  ']'] ,'FontSize', f.fontsize_title)
                    else  title(['[' ws.compname  '] ' ws.corrstat  '(' num2str(size(ws.d,1) -1) ')= '  num2str(ws.r,3) ', p='  ws.pp ],'FontSize', f.fontsize_title)
                    end
                    if ~ ws.rank_corr, ws.yl= ylim; hold on,plot([0,0],[ws.yl(1) ws.yl(2)],'k'); end  % Reference line
                    
                    
                    
                    ws=[];
                end
            end
            wd=[];
        end
    end
end
 
do.adhoccorr=0;
if do.adhoccorr;
    close all, figure('color','w')
     req.corr_type = 2; % 0=Auto, 1= Rank (Non-Parametric), 2= Normal (Parametric) 
    for o1=1:1
        %     wc.d1= d_ratesource{find(strcmp(logg.qs_ratesrc(:,1), 'Similar')),1}(:, 1)-d_ratesource{find(strcmp(logg.qs_ratesrc(:,1), 'Similar')),1}(:, 2);   wc.d1_name = ' C > D difference in ''Similar'' ratings';
        %     wc.d1= d_ratesource{find(strcmp(logg.qs_ratesrc(:,1), 'Similar')),1}(:, 1)-d_ratesource{find(strcmp(logg.qs_ratesrc(:,1), 'Similar')),1}(:, 3);   wc.d1_name = ' C > N difference in ''Similar'' ratings';
        %     wc.d1=    d_self(:, colslf.allscore) ;   wc.d1_name = 'Overall score';
        %     wc.d1=   dc_chosrc{1}(:,4) ;   wc.d1_name = 'p(Chose Inaccurate source)';
        %     wc.d1=      d_ratesource{find(strcmp(logg.qs_ratesrc(:,1), 'Suspicious')),1}(:, 4)  ;   wc.d1_name = '''Suspicious'' rating of Inaccurate source';
        %     wc.d1=      d_ratesource{find(strcmp(logg.qs_ratesrc(:,1), 'Competent')),1}(:, 4)  ;   wc.d1_name = '''Comptence'' rating of Inaccurate source';
        %     wc.d1=   dc_convertcat{1}(:,4)   ;   wc.d1_name = 'p(Converted by Inaccurate source)';
        
        % % Ratings about self
        %     wc.d1=  d_self(:, colslf.sourcelearn);   wc.d1_name = 'Self-rated ability to learn about sources';
        %     wc.d1=  d_self(:, colslf.checkall);   wc.d1_name = 'Performance on Checks';
        %     wc.d1=  d_self(:, colslf.checklearn);   wc.d1_name = 'Performance on Learning Checks';
        
        
        % Spillover suspicion 
        wc.d1=  d_self(:, colslf.pppSwAgr_NdmNc); wc.d1_name = 'p(Switch away from agreeing Nd) <  p(Switch away from agreeing Nc)';
         
%         wc.d2= dc_chosrc{1}(:,1)- dc_chosrc{1}(:,2); wc.dc_name='p(Choose C) >  p(Choose D)';
        
%         wc.d2= dc_chosrc{1}(:,3)- dc_chosrc{1}(:,2); wc.dc_name='p(Choose N) >  p(Choose D)';
            
            
            
            
        %     wc.d2= dc_chosrc{1}(:,1)- dc_chosrc{1}(:,3); wc.dc_name='p(Choose C) >  p(Choose N)';
        %     wc.d2= dc_chosrc{1}(:,1)- dc_chosrc{1}(:,4); wc.dc_name='p(Choose C) >  p(Choose I)';
        %     wc.d2= dc_chosrc{1}(:,2)- dc_chosrc{1}(:,4); wc.dc_name='p(Choose D) >  p(Choose I)';
        %     wc.d2= dc_chosrc{1}(:,3)- dc_chosrc{1}(:,4); wc.dc_name='p(Choose N) >  p(Choose I)';
%         wc.d2= d_ratesource{find(strcmp(logg.qs_ratesrc(:,1), 'similar')),2}(:,1);  wc.dc_name ='Similar rating, C>D';
        
        
        
    end
    for o=1:1 % Execute correlation
        switch req.corr_type;
            case 0
                [wc.h1, wc.p1] = kstest(wc.d1); [wc.h2, wc.p2] = kstest(wc.d2);
                if wc.p1<0.05 || wc.p2 <0.05;
                    [wc.k0,wc.k0,wc.k]=unique(wc.d1); wc.d1=(min(wc.k)+wc.k-1);
                    [wc.k0,wc.k0,wc.k]=unique(wc.d2); wc.d2=(min(wc.k)+wc.k-1);
                    wc.corrstat ='rs';  wc.rank_corr=1;  wc.nameprefix='[RANK]  ';
                else wc.corrstat ='r';  wc.rank_corr=0; wc.nameprefix=' ' ;
                end
            case 1; wc.corrstat ='r';  wc.rank_corr=0; wc.nameprefix=' ';
            case 2; wc.corrstat ='rs';  wc.rank_corr=1;  wc.nameprefix='[RANK]  ';
        end
        
        % Stats
        if wc.rank_corr, [wc.r wc.p]=  corr(wc.d1, wc.d2,'type','Spearman'); else [wc.r wc.p]=  corr( wc.d1, wc.d2); end
        if wc.p<0.05, wc.pp=  [num2str(wc.p,3) ' *'];  wc.col=[0.9 0 0]; elseif wc.p<0.1, wc.pp=  [num2str(wc.p,3) ' t'];  wc.col=[0.75 0 0]; else  wc.pp= num2str(wc.p,2);   wc.col=[0 0 0.7];   end
    end
    f.markersize=80; f.fontsize_title=20 ; f.fontsize=15;
    scatter(wc.d1, wc.d2,f.markersize, wc.col); hold on, lsline; set(gca,'FontSize', f.fontsize); ylabel(sprintf([wc.nameprefix wc.dc_name]),'FontSize', f.fontsize), xlabel(sprintf([wc.nameprefix wc.d1_name]),'FontSize', f.fontsize)
    title([wc.corrstat  '(' num2str(size(wc.d1,1) -1) ')= '  num2str(wc.r,3) ', p='  wc.pp ],'FontSize', f.fontsize_title); wc=[];
end


%% Execute correlatons via GLM 

 
close all
req.mixedglm_indivdiff = 0;  
if req.mixedglm_indivdiff
    % Set up correlations (not related to GLM, but executed in parallel)
    req.corr_type = 0; % 0=Auto, 1= Rank (Non-Parametric), 2= Normal (Parametric)
 
    for o=1:1 % Mixed GLM: i.e. subject x source  (different sources are split over different rows, subject dummy regressors needed ) 
           
        for o1=1:1 % Set up
            
            % Hard coded columns
            colmg.Subject = 1;
            colmg.Src = structmax(colmg)+1;
            colmg.pChoSrc = structmax(colmg)+1;
            colmg.pSwitchAgree = structmax(colmg)+1;
            colmg.pSwitchDisagree = structmax(colmg)+1;
            colmg.expAccuracy     = structmax(colmg)+1;   % Ordinal coded
            colmg.expConfirmatory = structmax(colmg)+1;   % Ordinal coded
            
            % Compile data
            d_mglm = nan(logg.n_subjs*4, 3);
            d_mglm(:, colmg.Subject) = repmat((1:logg.n_subjs)', 4,1);
            d_mglm(:, colmg.Src) =  sortrows(repmat((1:4)', logg.n_subjs,1));
            d_mglm(:, colmg.pChoSrc)  =  fvect(dc_chosrc{1}(:,1:4));
            d_mglm(:, colmg.pSwitchAgree)  =  fvect(dc_pswitch{1,1}(:,1:4));
            d_mglm(:, colmg.pSwitchDisagree)  =  fvect(dc_pswitch{2,1}(:,1:4));
            d_mglm(:, colmg.expAccuracy) = [ones(logg.n_subjs*3,1) ;  zeros(logg.n_subjs,1) ];  % Hard coded
            d_mglm(:, colmg.expConfirmatory) =  [3*ones(logg.n_subjs,1) ;  1*ones(logg.n_subjs,1) ;  2*ones(logg.n_subjs,1) ;  2*ones(logg.n_subjs,1)];  % Hard coded
            for r=1:size(logg.qs_ratesrc,1)   % Add all source ratings
                eval(['colmg.rate_' logg.qs_ratesrc{r,1} '= structmax(colmg)+1;'])
                eval(['d_mglm(:, colmg.rate_' logg.qs_ratesrc{r,1} ')= fvect(d_ratesource{r,1});'])
            end
            colmg.ProbScore = colmg.rate_ProbScore ;          
        end
        
        % Request
        req.IV = {
            %     'Src';
%             'expAccuracy';  'expConfirmatory'; 
            'rate_similar';
            'rate_predictable';
            'rate_competent';
            %     'rate_like';
            %     'rate_trust';
            %     'rate_useful';
            'rate_confident';
%             'rate_opposite';
            'rate_suspicious';
            };
        req.DV = {'pChoSrc'; 'pSwitchAgree'; 'pSwitchDisagree'; 'ProbScore'}; 
        
        % Set up for correlations
        f.plotcols= length(req.IV); f.plotrows=length(req.DV); f.markersize=10; f.fontsize_title=13; f.fontsize=10;
        f.figwidth= 1400; f.figheight=800; f.subplot_VerHorz=[0.15 0.08]; f.fig_BotTop=[0.1 0.1]; f.fig_LeftRight=[0.05 0.03];
        figure('Name',  'Correlations collapsed across all sources', 'Position', [100 50  f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
        
        
        % Execute GLMs 
        col.IVcols = [];  for i=1:length(req.IV),  eval(['colmg.IVcols(i)= colmg.' req.IV{i} ';']),  end
        rmg_beta  = [[{' '} req.DV'];   [req.IV cell( length(req.IV), length(req.DV))] ];
        rmg_sigbeta = rmg_beta; rmg_pval  = rmg_beta;
        disp('Mixed GLM + Collapsed-condition correlations ##################')
        for dv= 1:length(req.DV)
            eval(['wd.dvcol = colmg.' req.DV{dv} ';'])
            wd.dummysubs = repmat(eye(logg.n_subjs),4,1);  % Dummy subject regressors
                wd.iv = [d_mglm(:,colmg.IVcols) wd.dummysubs ];
%             wd.iv = [ f_featurenorm(d_mglm(:,colmg.IVcols)) wd.dummysubs ]; if dv==1, disp('Features normalized'); end 
            % Fit + record
            [ wd.bb wd.dev wd.st ] =  glmfit(wd.iv, d_mglm(:,wd.dvcol));
            rmg_pval(2:end, dv+1) = num2cell(wd.st.p(2:end-logg.n_subjs));
            rmg_beta(2:end, dv+1) =  num2cell(wd.bb(2:end-logg.n_subjs));
            
            % Markers
            ws.b=num2cell( wd.bb(2:end-logg.n_subjs));
            ws.p = wd.st.p(2:end-logg.n_subjs);
            ws.b(ws.p<0.001)= cellfun(@(x)[num2str(x,2) ' ***'],ws.b(ws.p<0.001), 'UniformOutput',0) ;
            ws.b(ws.p>0.001 & ws.p<0.01)= cellfun(@(x)[num2str(x,2) '  **'],ws.b(ws.p>0.001 & ws.p<0.01), 'UniformOutput',0) ;
            ws.b(ws.p>0.01 & ws.p<0.05)= cellfun(@(x)[num2str(x,2) ' *'],ws.b(ws.p>0.01 & ws.p<0.05), 'UniformOutput',0) ;
            ws.b(ws.p>0.05 & ws.p<0.1)= cellfun(@(x)[num2str(x,2) ' (t)'],ws.b(ws.p>0.05 & ws.p<0.1), 'UniformOutput',0) ;
            ws.b(ws.p>.1) =  cell(length(ws.b(ws.p>.1) ),1);
            rmg_sigbeta(2:end, dv+1) =ws.b; 
            
            % Straightforward correlation 
            for iv = 1: length(req.IV)
                subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1; 
                wi.dr= [d_mglm(:,[ colmg.Subject colmg.IVcols(iv)])   d_mglm(:,wd.dvcol)]; 
                for s=1:logg.n_subjs  
                    if s==1 && iv==1, disp('Mixed correlations: mean correcting DV and IV by subject (i.e. across conditions)'), end  
                    wi.dr(wi.dr(:, 1)==s, 2) =  wi.dr(wi.dr(:, 1)==s, 2)- mean(wi.dr(wi.dr(:, 1)==s, 2));  
                    wi.dr(wi.dr(:, 1)==s, 3) =  wi.dr(wi.dr(:, 1)==s, 3)- mean(wi.dr(wi.dr(:, 1)==s, 3));  
                end 
                wi.d  = wi.dr(:, 2:end); 
                wi.dd= wi.d;  wi.d= wi.d(~isnan(sum(wi.d,2)), :);
                 wi.var_names = {req.IV{iv}  req.DV{dv}}; 
                wi.compname  = strrep([req.IV{iv}  ' & ' req.DV{dv}], '_',  ' ');  
                 
                % What kind of correlation test?
                [wi.h1 wi.p1] = kstest(wi.d(:,1)); [wi.h2 wi.p2] = kstest(wi.d(:,2));
                if wi.p1<0.05 || wi.p2 <0.05; wi.rank_corr=1;
                else  wi.rank_corr=0;
                end
                if req.corr_type==1, wi.rank_corr=1; disp('Force RANK corr'),
                elseif req.corr_type==2, wi.rank_corr=0; disp('Force NORMAL corr (not rank)'),
                end
                
                % Stats
                if wi.rank_corr  % Implement correlation type
                    for v=1:2
                        [wi.k0,wi.k0,wi.k]=unique(wi.d(:,v));
                        wi.d(:,v)=(min(wi.k)+wi.k-1);
                    end
                    wi.corrstat ='rs'; wi.ylabel= ['(Rank)\n ' wi.var_names{2} ];    wi.xlabel= ['(Rank) ' wi.var_names{1} ];   
                    [wi.r wi.p]=  corr(wi.d(:,1), wi.d(:,2),'type','Spearman');
                else wi.corrstat ='r'; wi.ylabel= wi.var_names{2} ;  wi.xlabel= wi.var_names{1} ; 
                    [wi.r wi.p]=  corr(wi.d(:,1), wi.d(:,2) );
                end
                if wi.p<0.05, wi.pp=  [num2str(wi.p,3) ' *'];  wi.col=[0.9 0 0];
                elseif wi.p<0.1, wi.pp=  [num2str(wi.p,3) ' t'];  wi.col=[0.7 0 0];
                else wi.pp=  ' '; wi.col = [0.1 0.1 0.1];
                end
                
                % Scatter
                scatter(wi.d(:,1), wi.d(:,2),f.markersize, wi.col); hold on, lsline
                set(gca,'FontSize', f.fontsize), ylabel(sprintf(wi.ylabel),'FontSize', f.fontsize)
                if wi.p> 0.1, title(['[ ' wi.compname  ' ]'] ,'FontSize', f.fontsize_title)
                else  title(sprintf(['[ ' wi.compname  ' ]\n ' wi.corrstat  '(' num2str(size(wi.d,1) -1) ')= '  num2str(wi.r,3) ', p='  wi.pp ]),'FontSize', f.fontsize_title)
                end
                if ~ wi.rank_corr, wi.yl= ylim; hold on,plot([0,0],[wi.yl(1) wi.yl(2)],'k'); end  % Reference line
                xlabel(strrep(wi.xlabel, '_',  ' '))
                wi=[];  
            end
            ws=[];            
        end     
    end
end
    
% Fixed GLM (i.e. rows = subjects, not within-sub variables)
req.glm_indivdiff = 0;  
if req.glm_indivdiff
    req.do_plot = 1; 
    for o=1:1 % Mixed GLM: i.e. subject x source  (different sources are split over different rows, subject dummy regressors needed ) 
        % In retrospect I don't think is is a good way to look at the
        % different ratings, given that we already have good reason to
        % believe that the different ratings all move together (as a
        % function of our experimental design)
         
        for o1=1:1 % Set up
            
            % Subject-wise scores 
            colg.Subject = 1; 
            colg.rateslf_overall = structmax(colg)+1;
            colg.rateslf_sourcelearn = structmax(colg)+1;
            colg.rateslf_task = structmax(colg)+1;
            colg.rateslf_task_relative = structmax(colg)+1; 
            d_glm(:, colg.Subject) =  1:logg.n_subjs;        % Compile 
            d_glm(:, colg.rateslf_overall)      = d_self(:,colslf.overall); 
            d_glm(:, colg.rateslf_sourcelearn)  = d_self(:,colslf.sourcelearn); 
            d_glm(:, colg.rateslf_task)         = d_self(:,colslf.task); 
            d_glm(:, colg.rateslf_task_relative)= d_self(:,colslf.task_relative); 
            
            % Source scores  
            colg.pChoSrc =  structmax(colg)+1:structmax(colg)+4; 
            colg.pSwitchAgree  =  structmax(colg)+1:structmax(colg)+4; 
            colg.pSwitchDisagree = structmax(colg)+1:structmax(colg)+4;   
            d_glm(:, colg.pChoSrc)  =   dc_chosrc{1}(:,1:4);                % Compile 
            d_glm(:, colg.pSwitchAgree)  =   dc_pswitch{1,1}(:,1:4); 
            d_glm(:, colg.pSwitchDisagree)  =   dc_pswitch{2,1}(:,1:4);   
            for r=1:size(logg.qs_ratesrc,1)   % Add all source ratings
                eval(['colg.rate_' logg.qs_ratesrc{r,1} '= structmax(colg)+1:structmax(colg)+4;'])
                eval(['d_glm(:, colg.rate_' logg.qs_ratesrc{r,1} ')= d_ratesource{r,1};'])
            end
            colg.ProbScore = colg.rate_ProbScore ;          
        end
          
        % Request: 4 --> 1 glms [ p(Cho C/D/N/I) --> self perception of own competence ] 
        req.IV_persrc = {
            'pChoSrc'; 
            'pSwitchAgree'; 
            'pSwitchDisagree'; 
%             'ProbScore'
            };  % Order won't be preserved  
        req.IV =  sortrows([cellfun(@(x)[x '(1)'],  req.IV_persrc, 'UniformOutput', 0); 
                 cellfun(@(x)[x '(2)'],  req.IV_persrc, 'UniformOutput', 0); 
                cellfun(@(x)[x '(3)'],  req.IV_persrc, 'UniformOutput', 0); 
                cellfun(@(x)[x '(4)'],  req.IV_persrc, 'UniformOutput', 0);] );   
        req.DV = {
            'rateslf_sourcelearn';
            'rateslf_overall';  
            'rateslf_task'; 
            'rateslf_task_relative'
            };
        
        
%         




%         d_self(:, colslf.task)
%         
%         
%         
%         [b d st] = glmfit(f_featurenorm( [dc_chosrc{1}(:,1:4)  dc_pswitch{2,1}(:,1:4)]), d_self(:, colslf.task)); 
%         
%         st.p
%         b
        
        
        
        
        % Execute #########################################################################
        if req.do_plot   % Plot
            f.plotcols= 2; f.plotrows=3;  f.fontsize=15;  f.fontsize_title=15;  f.fontsize_small=10; f.col =[123, 247, 206]/256; 
            f.figwidth= 1500; f.figheight=1000; f.subplot_VerHorz=[0.15 0.08]; f.fig_BotTop=[0.1 0.05]; f.fig_LeftRight=[0.1 0.1];
            f.marksig_y = 1.2;  f.marksig_color =[0,0,0]/256; 
            figure('Name', ['Approach-C vs Avoid-D? (n=' num2str(logg.n_subjs) ')'], 'Position', [1500 50 f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
        end 
        col.IVcols = [];  for i=1:length(req.IV ),  eval(['colg.IVcols(i)= colg.' req.IV{i} ';']),  end
        rg_beta  = [[{' '} req.DV'];   [req.IV cell( length(req.IV), length(req.DV))] ];
        rg_sigbeta = rg_beta; rg_pval  = rg_beta;
        for dv= 1:length(req.DV)
            eval(['wd.dvcol = colg.' req.DV{dv} ';'])
%             wd.iv =   f_featurenorm( d_glm(:,colg.IVcols) ); 
            wd.iv =   d_glm(:,colg.IVcols);  
            
            % Fit + record
            [ wd.bb wd.dev wd.st ] =  glmfit(wd.iv, d_glm(:,wd.dvcol));
            rg_pval(2:end, dv+1) = num2cell(wd.st.p(2:end));
            rg_beta(2:end, dv+1) =  num2cell(wd.bb(2:end));
               
            % Markers
            ws.b=num2cell( wd.bb(2:end));
            ws.p = wd.st.p(2:end); 
            ws.b(ws.p<0.001)= cellfun(@(x)[num2str(x,2) ' ***'],ws.b(ws.p<0.001), 'UniformOutput',0) ;
            ws.b(ws.p>0.001 & ws.p<0.01)= cellfun(@(x)[num2str(x,2) '  **'],ws.b(ws.p>0.001 & ws.p<0.01), 'UniformOutput',0) ;
            ws.b(ws.p>0.01 & ws.p<0.05)= cellfun(@(x)[num2str(x,2) ' *'],ws.b(ws.p>0.01 & ws.p<0.05), 'UniformOutput',0) ;
            ws.b(ws.p>0.05 & ws.p<0.1)= cellfun(@(x)[num2str(x,2) ' (t)'],ws.b(ws.p>0.05 & ws.p<0.1), 'UniformOutput',0) ;
            ws.b(ws.p>.1) =  cell(length(ws.b(ws.p>.1) ),1);
            rg_sigbeta(2:end, dv+1) =ws.b;  % Print beta anyway 
            
            if req.do_plot 
                wf.d = wd.bb(2:end); wf.p = ws.p; 
                subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
                wf.nm =   cellfun(@(x)x(1:end-3), req.IV, 'UniformOutput', 0);  wf.nm_unique  =  unique(wf.nm); 
                for j=1:length(wf.nm_unique)  
                    wf.wh = find(strcmp(wf.nm, wf.nm_unique{j})); 
                    wf.br(j) = bar(min(wf.wh):max(wf.wh), wf.d(wf.wh),  'FaceColor',  abs(f.col-(j*0.3))); hold on  
                    wf.xcord = fmat(min(wf.wh):max(wf.wh),  find(wf.p(wf.wh)<0.05));
                    hold on, scatter(wf.xcord , ones(sum(wf.p(wf.wh)<0.05),1)*f.marksig_y ,100, '+', 'MarkerEdgeColor', f.marksig_color, 'LineWidth', 2) 
                    wf.xcord = fmat(min(wf.wh):max(wf.wh),  find(wf.p(wf.wh)>0.05 & wf.p(wf.wh)<0.1));
                    hold on, scatter(wf.xcord , ones(sum(wf.p(wf.wh)>0.05 & wf.p(wf.wh)<0.1),1)*f.marksig_y , '.', 'MarkerEdgeColor', f.marksig_color, 'LineWidth', 2) 
                end  
                legend(wf.br, req.IV_persrc);                  
                ylabel('Beta value','FontSize', f.fontsize) , title(req.DV{dv},'FontSize', f.fontsize_title );
%                 set(gca,  'xtick',  1:length(wf.d), 'xticklabel', req.IV,'FontSize', f.fontsize_small) 
                set(gca,  'xtick',  1:length(wf.d), 'xticklabel', repmat(logg.src, 1,length(req.IV_persrc)),'FontSize', f.fontsize) 
                xlim([0.5 length(req.IV)+0.5]), ylim auto 
            end
            

        end     
        openvar rg_sigbeta   
        openvar rg_beta
        
    end
end
 



      
%% Ad-hoc analysis/code

do.this =0;
if do.this
    % Plots for self ratings
    f.plotcols= length(logg.qs_self); f.plotrows= 1;  f.fontsize_title=20; f.fontsize=15; f.figwidth= 1000; f.figheight=1000;
    f.subplot_VerHorz=[0.1 0.1]; f.fig_BotTop=[0.15 0.15]; f.fig_LeftRight=[0.1 0.1];
    f.plotcols= 3; f.plotrows= 3;  f.fontsize_title=20; 
    figure('Name','Self ratings', 'Position', [150 50 f.figwidth f.figheight], 'Color', 'w','number', 'off'); k=1;
    
    for i=1:length(logg.qs_self)
        
        wi.d = d_self(:,i);
        subtightplot(f.plotrows, f.plotcols , k ,f.subplot_VerHorz,f.fig_BotTop, f.fig_LeftRight); k=k+1;
        hist( wi.d); h =findobj(gca, 'Type','patch');  set(h, 'FaceColor', 'y');
        title(logg.qs_self{i}, 'FontSize', f.fontsize_title)
        set(gca, 'FontSize', f.fontsize), ylabel('N subjects')
        %
        wi.ytop = ylim; if strcmp(logg.qs_self{i}, 'ProbScore')==0 & strcmp(logg.qs_self{i}, 'Probabilistic score')==0,  xlim([1 10]), else, xlim auto; end
        hold on; plot(repmat(mean(wi.d),2,1), [0 wi.ytop(2)+1], 'LineWidth', 2, 'Color','r')
        wi=[];
    end
     
    wi.d = d_ratesource{find(strcmp(logg.qs_ratesrc(:,1), 'similar')),    2}(:,1); wi.title= 'C>D Similarity rating';   % C > D Similarity rating
    figure('color','w'),  hist( wi.d); h =findobj(gca, 'Type','patch');  set(h, 'FaceColor', 'y');
    title(wi.title, 'FontSize', f.fontsize_title), ylabel('N subjects', 'FontSize', f.fontsize)
    set(gca, 'FontSize', f.fontsize) 
end
  
do.this =0;
if do.this 
w.probscore = fvect( d_ratesource{find(strcmp(logg.qs_ratesrc(:,1), 'ProbScore')),1});
w.switch =  fvect(dc_pswitch{2,1}(:,1:4)); w.switch(isnan(w.switch))=0;  
% w.switch =  fvect( dc_pswitch{2,1}(:,1:4) + (1-dc_pswitch{1,1}(:,1:4))); w.switch(isnan(w.switch))=0;  
corr(w.probscore, w.switch)
end


for o=1:1  % GLM control for experienced accuracies
    do.this=0;
    if do.this
        % Simplified variable holders
        ds_srcacc=dck_srcacc{1}(:,1:4);
        ds_chosrc=dc_chosrc{1}(:,1:4);
        
        
        
        clc
        dd = [
            (1:logg.n_subjs)' ones(logg.n_subjs,1)   ds_srcacc(:,1)   ds_chosrc(:,1)
            (1:logg.n_subjs)' 2*ones(logg.n_subjs,1)   ds_srcacc(:,2)     ds_chosrc(:,2)
            ]  ;
        
        disp('With Accuracy --------------')
        wd.iv={' ', 'Sub', 'Cond', 'Acc'};
        [wd.b wd.b wd.st]=glmfit(dd(:,1:end-1), dd(:,end));
        disp([wd.iv' num2cell(wd.st.beta) num2cell(wd.st.p)])
        
        dd = [
            (1:logg.n_subjs)'   ones(logg.n_subjs,1)    ds_chosrc(:,1)
            (1:logg.n_subjs)'    2*ones(logg.n_subjs,1)      ds_chosrc(:,2)
            ]  ;
        
        disp('Without Accuracy --------------')
        wd.iv={' ', 'Sub', 'Cond'};
        [wd.b wd.b wd.st]=glmfit(dd(:,1:end-1), dd(:,end));
        disp([wd.iv' num2cell(wd.st.beta) num2cell(wd.st.p)])
        
        
        %
        clc
        dd = [ds_srcacc(:,1)-ds_srcacc(:,2)   ds_chosrc(:,2)-ds_chosrc(:,1)
            ]  ;
        [wd.h wd.p wd.ci wd.st]= ttest(dd);
        disp('Raw preference --------------')
        [wd.st.tstat(2) wd.p(2)]
        disp('Preference after removing acc effects --------------')
        [wd.b wd.b wd.st]=glmfit(dd(:,1), dd(:,2));
        [wd.h wd.p wd.ci wd.st]= ttest(wd.st.resid);
        [wd.st.tstat(1) wd.p]
    end
end
    
%% Subject sub-samples 

do.this = 0; 
if do.this
    for o=1:1  % Subject's own choices
        
        % Subjects whose pyes is acceptable (1st guess must be a real guess)
        ws.bound=0.15;
        ws.learn_ok= (cellfun(@(x)mean(x(:,coll.choice)), subjdata(:,2))>ws.bound) &  (cellfun(@(x)mean(x(:,coll.choice)), subjdata(:,2))<(1-ws.bound));
        ws.cho1_ok= cellfun(@(x)mean(x(:,colc.choice1)), subjdata(:,3))>ws.bound & cellfun(@(x)mean(x(:,colc.choice1)), subjdata(:,3))<(1-ws.bound);
        ws.pyesok= ws.learn_ok & ws.cho1_ok;
%         rsubs.pyes15=  {'A10G57EYF3HK46';'A11O504U2EJUGU';'A11YS0T8MV3Q7C';'A14ADQ7RUN6TDY';'A1945USNZHTROX';'A1BRJXBMTURQNT';'A1D0EMMFF1L9YA';'A1DS5O8MSI3ZH0';'A1EN3FW93BSXQQ';'A1F9KLZGHE9DTA';'A1IFF4KV23FGHJ';'A1IFIK8J49WBER';'A1N4AZ1QXPOPXH';'A1TLNLB9D87H6';'A207IHY6GERCFO';'A258IQXX7F3Z8O';'A2EI075XZT9Y2S';'A2NZ7RMSBXESNI';'A2T2RV6G8AMC7Y';'A2U7BMG19Q83GE';'A2WH3GIS2KF8LU';'A2WITLR6U5CW68';'A2YCMT5BPA0AG9';'A2YKW761AK4ZGY';'A341XKSRZ58FJK';'A35HVY5S3USKZS';'A35LCVF2Q3Z2TI';'A37EV8RZ82WT8E';'A3CIUPLZ6614U2';'A3JI3B5GTVA95F';'A3JT22BLG866CK';'A3L2UB07EZJAMD';'A3OP6TQ0OXBXE3';'A3PJ51GS2AKBO6';'A3QLGMZOLGMBQ1';'A4IEHQI7RBRDX';'A6JKKANO7F4KD';'ABUXM7VAW5SKJ';'ABZ9JFOPNYTGE';'AD1WGUMVD6KED';'AFZKP8TAXAUCR';'ANK8K5WTHJ61C';'APZEIAO75NCHM';'AT3C00TKZK13L'};
%         disp('Subjects with mostly acceptable pYes (overall):'), logg.subjects(ws.pyesok)
        
        % People who think they're good at identifying blaps
        ws.d=sortrows([logg.subjects num2cell(d_self(:, colslf.task))],2);
        
        % People who think they're relatively good at identifying blaps
        ws.d=sortrows(   [logg.subjects num2cell(d_self(:, colslf.task_relative))]   , 2);
        
        % People who think they're relatively good at the task overall (own + using source's guess)
        ws.d=sortrows([logg.subjects num2cell(d_self(:, colslf.overall))],2);
        
        % People w good probabilistic score (good at using source info, taking into account src accuracy)
        ws.d=sortrows([logg.subjects num2cell(d_self(:, colslf.probscore))],2);
        
        % People w good scores on checks
        ws.d=sortrows([logg.subjects num2cell(d_self(:, colslf.checklearn))],2);
        
        % People w good scores on checks
        ws.d=sortrows([logg.subjects num2cell(d_self(:, colslf.checkall))],2);
        
        ws=[];
    end
    for o=1:1 % Learning about source accuracy
        
        % People who think they're good at learning about the sources
        ws.d=sortrows([logg.subjects num2cell(d_self(:, colslf.sourcelearn))],2);
        
        % People who choose I the least often
        ws.d=sortrows([logg.subjects num2cell(    dc_chosrc{1}(:,4)    )],2);
        
        % People who rate I as least competent (simple effect, C/D/N>I)
        ws.dd=d_ratesource{find(strcmp(logg.qs_ratesrc(:,1), 'competent')),1};
        ws.d=sortrows([logg.subjects num2cell(    mean(ws.dd(:,1:3),2) - ws.dd(:,4)    )],2);
        
        % People who rate similarity C>D biggest diff
        ws.dd=d_ratesource{find(strcmp(logg.qs_ratesrc(:,1), 'similar')),1};
        ws.d=sortrows([logg.subjects num2cell(     ws.dd(:,1)- ws.dd(:,2)    )],2);
         
        % People who rate competence C>D biggest diff
        ws.dd=d_ratesource{find(strcmp(logg.qs_ratesrc(:,1), 'competent')),1};
        ws.d=sortrows([logg.subjects num2cell(     ws.dd(:,1)- ws.dd(:,2)    )],2);
        
        % People who are least converted by disagreeing-I (some people dont have a rate at all, they never choose I. Those are considered the lowest converted)
        ws.dd= dc_pswitch{2,1}(:,4); ws.dd(isnan(ws.dd))=0;
        ws.d=sortrows([logg.subjects num2cell(ws.dd )],-2);
        
        % Probabilistic score C/D/N > I   
        ws.dd=   d_ratesource{find( strcmp(logg.qs_ratesrc(:,1), 'ProbScore')),1}; 
        ws.d=sortrows([logg.subjects num2cell(     mean(ws.dd(:,1:3),2)  - ws.dd(:,4)    )],2);
         
        % Probabilistic score  N > I   
        ws.dd=   d_ratesource{find( strcmp(logg.qs_ratesrc(:,1), 'ProbScore')),1}; 
        ws.d=sortrows([logg.subjects num2cell(     mean(ws.dd(:,3),2)  - ws.dd(:,4)    )],2);
         
        
        openvar ws.d
    end
    
    for o=1:1 % AFC 
 
        % AFC accuracy
        ws.d=sortrows([logg.subjects num2cell(nanmean(df_simacc{1},2))],2);
        
         
        
        % How are subjects doing on the checks ?
       ws.d =  sortrows([logg.subjects num2cell(d_self(:, [colslf.checklearn colslf.checkchoice colslf.checkall]))],2);
        
       
       % AFC performance rates
       cols = [0 0.7]; figure,  
       subplot(1,2,1), imagesc(df_simacc{1}), colorbar, caxis(cols)
       subplot(1,2,2), imagesc(df_simaccnoi{1}), colorbar, caxis(cols)
 
        
       
       logg.subjects( nanmean(df_simacc{1},2) >= 0.60)  
       logg.subjects( nanmean(df_simaccnoi{1},2) >= 0.6 ) 
        
       logg.subjects( nanmean(df_simaccnoi{1},2) >= 0.7) 
        
    end 
    
    for o= 1:1 % DVs of interest 
         
        % ChoSrc (mean pref): C>D 
        ws.d=sortrows( [logg.subjects num2cell(  dc_chosrc{2}(:,  strcmp(logg.srccomp(:,1), 'CD') ))],2 );
         
         
        
        
        openvar ws.d
        
    end
end 
  
 
 %% Export  
 
do.export=0;
for o=1:1 
close all
if do.export
    nc = @num2cell;  cond =logg.src;
    c= 1;  header={};  data ={};
     
    header{c}= 'Version';   data(:, c) =  repmat({'v3.2'}, logg.n_subjs,1);  c=c+1;
    header{c}= 'Subject';   data(:, c)=logg.subjects;  c=c+1;
    header{c}= 'ProbScore';   data(:, c)=nc(d_self(:, colslf.probscore));  c=c+1;
    header{c}= 'slf_task';   data(:, c)=nc(d_self(:, colslf.task));  c=c+1;
    header{c}= 'slf_taskrelative';   data(:, c)=nc(d_self(:, colslf.task_relative));  c=c+1;
    header{c}= 'slf_sourcelearn';   data(:, c)=nc(d_self(:, colslf.sourcelearn));  c=c+1;
    
    % Condition means
    for sr=1:4 % pCho
        header{c}=['pChoSrc_' cond{sr}]; data(:, c)= nc(dc_chosrc{1}(:, sr)); c=c+1;
    end
    for sr=1:4 % ChoSource RT
        header{c}=['ChoSrcRT_' cond{sr}]; data(:, c)= nc(dc_infort{1}(:, sr)); c=c+1;
    end
    for sr=1:4 % Accuracy
        header{c}=['SrcAcc_' cond{sr}];
        data(:, c)= nc(dck_srcacc{1}(:, sr));
        c=c+1;
    end
    for sr=1:4 % Src Agreement
        header{c}=['LearnSrcAgr_' cond{sr}];
        data(:, c)= nc(dck_srcagree{1}(:, sr));
        c=c+1;
    end
     for sr=1:4 % ChoSrc Agreement
        header{c}=['ChoSrcAgr_' cond{sr}];
        data(:, c)= nc(dck_srcagree{1}(:, 5+sr));
        c=c+1;
     end  
    for sr=1:4 % Switch if src agrees
        header{c}=['pSwitchSrcAgree_' cond{sr}];
        data(:, c)= nc(dc_pswitch{1,1}(:, sr));
        c=c+1;
    end
    for sr=1:4 % Switch if src disagrees
        header{c}=['pSwitchSrcDisagree_' cond{sr}];
        data(:, c)= nc(dc_pswitch{2,1}(:, sr));
        c=c+1;
    end
    for sr=1:4 % Prob Score
        header{c}=['ProbScore_' cond{sr}];
        data(:, c)= nc(     d_ratesource{ find(strcmp(logg.qs_ratesrc(:,1), 'ProbScore')), 1}(:,sr)     );
        c=c+1;
    end
    req.export_ratings = {'competent' 'competent' ; 'similar' 'similar'; 'like' 'like';'trust' 'trust'};   % col 1 = search name , col 2 = name for new file
    for r=1:length(req.export_ratings) % Ratings
        for sr=1:4
            header{c}=['ra_' req.export_ratings{r,2} '_' cond{sr}];   % Change here to change name for output file
            data(:, c)= nc(     d_ratesource{ find(strcmp(logg.qs_ratesrc(:,1), req.export_ratings{r,1})), 1}(:,sr)     );
            c=c+1;
        end
    end
    
    % Presented pairs
    for pp=1:6  % Cho Source
        header{c}=['pChoSrc_' logg.srccomp{pp,1} ];
        data(:, c)= nc(dc_chosrc{3}(:,pp));
        c=c+1;
    end
    for pp=1:6 % Cho Source RT
        header{c}=['ChoSrcRT_' logg.srccomp{pp,1} 'm'];  % Mean
        data(:, c)= nc(dc_infort{3}(:,(pp-1)*3+1));
        c=c+1;
        header{c}=['ChoSrcRT_' logg.srccomp{pp,1} '1'];  % 1st option
        data(:, c)= nc(dc_infort{3}(:,(pp-1)*3+2));
        c=c+1;
        header{c}=['ChoSrcRT_' logg.srccomp{pp,1} '2'];  % 2nd option
        data(:, c)= nc(dc_infort{3}(:,(pp-1)*3+3));
        c=c+1;
    end
    for pp=1:6 % p(Switch|Agree)
        header{c}=['pSwitchSrcAgree_' logg.srccomp{pp,1} 'm'];  % Mean
        data(:, c)= nc(dc_pswitch{1,3}(:,(pp-1)*3+1));
        c=c+1;
        header{c}=['pSwitchSrcAgree_' logg.srccomp{pp,1} '1'];  % 1st option
        data(:, c)= nc(dc_pswitch{1,3}(:,(pp-1)*3+2));
        c=c+1;
        header{c}=['pSwitchSrcAgree_' logg.srccomp{pp,1} '2'];  % 2nd option
        data(:, c)= nc(dc_pswitch{1,3}(:,(pp-1)*3+3));
        c=c+1;
    end
    for pp=1:6 % p(Switch|Disagree)
        header{c}=['pSwitchSrcDisagree_' logg.srccomp{pp,1} 'm'];  % Mean
        data(:, c)= nc(dc_pswitch{2,3}(:,(pp-1)*3+1));
        c=c+1;
        header{c}=['pSwitchSrcDisagree_' logg.srccomp{pp,1} '1'];  % 1st option
        data(:, c)= nc(dc_pswitch{2,3}(:,(pp-1)*3+2));
        c=c+1;
        header{c}=['pSwitchSrcDisagree_' logg.srccomp{pp,1} '2'];  % 2nd option
        data(:, c)= nc(dc_pswitch{2,3}(:,(pp-1)*3+3));
        c=c+1;
    end
    
    
    % Export
    dd = data(:, 3:end);  dd=dd(:);  dd(isnan(cell2mat(dd(:))))= cell(sum(isnan(cell2mat(dd(:)))),1); % Rid nans
    data= [data(:, 1:2) reshape(dd, logg.n_subjs,size(data,2)-2)];
    pr = print2txt('C:\Users\e.loh\Dropbox\SCRIPPS\3_ConfirmInfo\3 Data\v24_to_v32', 'Data_v32', [header; data]);
    pr
    
end
end

%% End

disp('#########################################################'), disp('Alterations made to data:'), disp(char(req.alter(:)))
disp('Preprocessing decisions:'), disp(req.preproc)
