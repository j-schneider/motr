function [strctIdentityClassifier,acHOGFeaturesCulled]= ...
  fnCullExemplarsAndTrainTdistIdentityClassifiers(acHOGFeatures, ...
                                                  acA, ...
                                                  acB)

% Set the number of exemplars used for ID classifiers
iMaxNumExemplars=20000;

% I don't think this is ever used anywhere else, and it's an odd thing to 
%   do, so we'll skip it.
% g_strctGlobalParam.m_strctClassifiers.m_fMaxSamplesPerMouseForIdentityTraining = ...
%     iMaxNumExemplars;
% If anything, we should be _reading_ it from a global

% Cull a bunch of random exemplars from big-enough ellipses
fnLog('Collecting exemplars');
acHOGFeaturesCulled = ...
  fnCullExemplarsFromSMTracks(acHOGFeatures, ...
                              acA,acB, ...
                              iMaxNumExemplars);
                            
% Train the classifiers that discriminate each mouse from all others
strctIdentityClassifier = ...
  fnTrainTdistIdentitiesFromCellArray(acHOGFeaturesCulled);

end
