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
if obj.players{fromPlayer}.cards.(string(fromResource)) < numFrom
    isValid = false; return
    % Does the trade partner have enough cards?
elseif obj.players{toPlayer}.cards.(string(toResource)) < numTo
    isValid = false; return
end

% If the trade is valid, conduct it
obj.players{fromPlayer}.cards.(string(fromResource)) = ...
    obj.players{fromPlayer}.cards.(string(fromResource)) - numFrom;
obj.players{toPlayer}.cards.(string(fromResource)) = ...
    obj.players{toPlayer}.cards.(string(fromResource)) + numFrom;
obj.players{toPlayer}.cards.(string(toResource)) = ...
    obj.players{toPlayer}.cards.(string(toResource)) - numTo;
obj.players{fromPlayer}.cards.(string(toResource)) = ...
    obj.players{fromPlayer}.cards.(string(toResource)) + numTo;

end

