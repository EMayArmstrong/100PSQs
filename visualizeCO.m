function h = visualizeCO(G, varargin)
%
% visualizeCO.m                             Copyright 2020, The MathWorks, Inc.
%
% Visualize Co-occurence network
%
% Syntax: h = visualizeCO(G [,parameter, value, ...])
%
% Input:
%   G [graph Object] -> The Co-occurence network. (Output of createCONetwork.m)
%   
% Parameter-Value pairs specifying Node/Edge/Text color:
%
%    'NodeColor','EdgeColor','TextColor'  [RGB triplet, or Matrix of which each
%                                          row is RGB triplet.
%
%    'EdgeWidth' [doble]  If you specify 'EdgeWidth', it overwrites the weight
%                         of each edge of G.
%
% Output: h [handle of GraphPlot object]
%

%% Manage input
p = inputParser;

addRequired(p,'G', @(x) isa(x,'digraph'));
addParameter(p,'NodeColor',[0.8 0.8 0.8]);
addParameter(p,'EdgeColor',[0.5 0.5 0.5]);
addParameter(p,'TextColor',[0.0 0.0 0.0]);
addParameter(p,'MarkerSize',36);
addParameter(p,'FontSize',9);
addParameter(p,'EdgeWidth','auto');

parse(p,G,varargin{:});

%% Set Node color
switch class(p.Results.NodeColor)
    case {'char','string'}
        switch p.Results.NodeColor
            case 'auto'
                prmNodeColor = 'NodeCData';
                valNodeColor = p.Results.G.Nodes.Counts;
            otherwise
                prmNodeColor = 'NodeCData';
                valNodeColor = p.Results.G.Nodes.Counts;
        end
    
    case 'double'
        prmNodeColor = 'NodeColor';
        valNodeColor = p.Results.NodeColor;
end

%% Set Edge color
switch class(p.Results.EdgeColor)
    case {'char','string'}
        switch p.Results.EdgeColor
            case 'auto'
                prmEdgeColor = 'EdgeCData';
                valEdgeColor = p.Results.G.Edges.Weight;
            otherwise
                prmEdgeColor = 'EdgeCData';
                valEdgeColor = p.Results.G.Edges.Weight;
        end
    
    case 'double'
        prmEdgeColor = 'EdgeColor';
        valEdgeColor = p.Results.EdgeColor;
end

%% Set Edge width

prmEdgeWidth = 'LineWidth';
ew = p.Results.G.Edges.Weight;

switch class(p.Results.EdgeWidth)
    case {'char','string'}
        switch p.Results.EdgeWidth
            case 'auto'
                valEdgeWidth = 0.5+(ew-min(ew))/(max(ew)-min(ew))* 6;
            otherwise
                valEdgeWidth = 0.5;
        end
    
    case 'double'
        valEdgeWidth = p.Results.EdgeWidth;
end

%% Draw network graph

h = plot(G,...
  prmEdgeColor,valEdgeColor,...
  prmNodeColor,valNodeColor,...
  prmEdgeWidth,valEdgeWidth,...
  'ArrowSize',2*valEdgeWidth+4,...
  'MarkerSize',p.Results.MarkerSize,...
  'Layout','force','UseGravity',true,'Iterations',100);

% Since the position of the node label cannot be in the center of the circle,
% we need to erase the existing label and overlay the text so that each label is
% on the center of each circle.
text(h.XData, h.YData, h.NodeLabel,'HorizontalAlignment','center',...
  'VerticalAlignment','middle','FontSize',p.Results.FontSize,...
  'Color',p.Results.TextColor);

h.NodeLabel = [];

end
