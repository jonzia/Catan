function [obj, isValid] = tradePlayer(obj, fromPlayer, toPlayer, fromResource, ...
    toResource, numFrom, numTo)

% -------------------------------------------------------------------------
% This function conducts a trade of cards between two players.
%
% Arguments:
% - fromPlayer      Int         Player from which trade is originating
% - toPlayer        Int         Player with which trade is being made
% - fromResource    Resource    Resource from originating player
% - toResource      Resource    Resource to be acquired
% - numFrom         Int         Number of cards from originating player
% - numTo           Int         Number of cards to originating player
% -------------------------------------------------------------------------

% Determine whether this trade is valid; if not, return
isValid = true;
% Does the originating player have enough cards?
if obj.player{fromPlayer}.cards.(string(fromResource)) < numFrom
    isValid = false; return
    % Does the trade partner have enough cards?
elseif obj.player{toPlayer}.cards.(string(toResource)) < numTo
    isValid = false; return
end

% If the trade is valid, conduct it
obj.player{fromPlayer}.cards.(string(fromResource)) = ...
    obj.player{fromPlayer}.cards.(string(fromResource)) - numFrom;
obj.player{toPlayer}.cards.(string(fromResource)) = ...
    obj.player{toPlayer}.cards.(string(fromResource)) + numFrom;
obj.player{toPlayer}.cards.(string(toResource)) = ...
    obj.player{toPlayer}.cards.(string(toResource)) - numTo;
obj.player{fromPlayer}.cards.(string(toResource)) = ...
    obj.player{fromPlayer}.cards.(string(toResource)) + numTo;

end

