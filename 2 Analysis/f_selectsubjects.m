function [subjectlist n_subjs newdatalog] = f_selectsubjects(olddatalog, specificsubjects,koshertable, modelname)
% [subjectlist n_subjs newdatalog] = f_selectsubjects(olddatalog, specificsubjects,koshertable, modelname)
%  Select subjects, applying criteria (1) whether data is good (koshertable; applied first), 
%                                                   and then (2) specific subjects (specificsubjects; if requested)
%
%   olddatalog:           datalog, loaded from .mat file in data directory
%   specificsubjects:   cell array with names of specifically-requested subjects
%   koshertable:        cell array, read from excel document   'i_subjectdataok_secondlevel.xlsx'
%                                   - Note: If details of excel sheet are changed (e.g. columns), this function
%                                      must be amended (variable 'excel')
%   modelname:        name of onsets model (including memory type, e.g.  m_c1_Contextall_Rem)
%
%   NOTE:
%   (1) To include all subjects regardless of data-legitimacy, specify 'all' as model
%           - Otherwise, if requested subjects are not kosher, this is flagged but ultimately allowed
%   (2) Generally, analysis is performed on all subjects up til 2nd level, to allow for exploratory inclusions. 
%
% ------------------------------------------------------------------------------------
% 
% % Execute following to debug with script:  
% olddatalog=logg.datalog; specificsubjects=logg.specificsubjects; koshertable=log.koshertable; 
% log.koshertable= [logg.datalog vertcat('include_all', num2cell(ones(size(logg.datalog,1)-1,1)))]
% 'include_all'

%% Identifying subjects with good (kosher) data

% Details in excel sheet (koshertable) *** 
excel.firstmodel_col=2;
excel.firstsubjectname_row=2;

% Which model = which kosherlist?
for i=excel.firstmodel_col:size(koshertable,2); allmodels{i-excel.firstmodel_col+1,1}=koshertable{1,i}; end
if length(find(strcmp(modelname,allmodels)))~=1; error(['Error in selecting subjects according to legitimacy of data: Could not find column for requested model  (' modelname ')']); end

% List of subjects with kosher data
j=1;  
for i=excel.firstsubjectname_row:size(koshertable,1); 
    if koshertable{i, excel.firstmodel_col-1+find(strcmp(modelname,allmodels))}==1
        kosherlist{j,1}=koshertable{i,1};
        j=j+1;
    end
end

% Check: are specifically-requested subjects kosher? 
for i=1: length(specificsubjects)
    if sum(strcmp(specificsubjects{i},kosherlist))~=1
        disp(['Error: Requested specific subject (' specificsubjects{i} ') does not have good data (according to 2nd level table)'])
        input('          Hit enter to continue & include this subject. Otherwise, amend list of requested subjects   ')
    end
end

%% Integrating kosher-ness & request list: Which subjects to include?

if isempty(specificsubjects)==1
    subjectlist=kosherlist;
else
    subjectlist=specificsubjects;
end

%% Write details for subjects to be included 

newdatalog=cell(length(subjectlist)+1,size(olddatalog,2));
subjectlist=sortrows(subjectlist); % Always in alphabetical order

% Re-write headers
for i=1:size(olddatalog,2)
    newdatalog{1,i}=olddatalog{1,i};
end

% Grab details from requested subjectlist
for i=1:length(subjectlist)
    w.sok=0;
    while w.sok==0
        for j=2:size(olddatalog,1)
            if strcmp(olddatalog{j,1}, subjectlist{i})==1
                for k=1:size(olddatalog,2)
                    newdatalog{1+i,k}=olddatalog{j,k};
                end
                w.sok=1;
            end
            if w.sok==0 && j==size(olddatalog,1)
                error(['Error: Could not find requested specific subject (' subjectlist{i} ')']);
            end
        end
    end
end

% Record no. of subjects
n_subjs=size(newdatalog,1)-1;


end
