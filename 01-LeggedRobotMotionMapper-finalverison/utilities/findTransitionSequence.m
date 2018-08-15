function transitionSequence = findTransitionSequence(stateSequence)
% transitionSequence function counts time in units of the transitions between states
% given the input stateSequence
% the transitionSequence always have S(n+1) ~= S(n)\
%
% (C) Aaron Z Guan, 2018
%     Terradynamics Lab, JHU
transitionSequence = {};
for j = 1 : length(stateSequence)
    n = 1;
    for i = 1 : (length(stateSequence{j})-1)
        if stateSequence{j}(i) ~= stateSequence{j}(i+1)
            transitionSequence{j}(n) = stateSequence{j}(i);
            transitionSequence{j}(n+1) = stateSequence{j}(i+1);
            n = n+1;
        end
    end
end