%% Processing Input Data
for i = 1:length(input_data)
    egonet(i).edges = [input_data{i,:}];
    if isempty(egonet(i).edges) ~= 1
    egonet(i).G = digraph(egonet(i).edges(:,1),egonet(i).edges(:,2),egonet(i).edges(:,3));
    
    if Plot == 1
    ego = numnodes(egonet(i).G);
    
    pre_nodes = predecessors(egonet(i).G,ego);
    suc_nodes = successors(egonet(i).G,ego);
    neigh = unique([pre_nodes;suc_nodes]);
    
    figure(i)
    F(i) = plot(egonet(i).G);% for showing weight: ,'EdgeLabel',egonet(i).G.Edges.Weight);
    layout(F(i),'force3','UseGravity',true)
%     layout(F(i),'force3','WeightEffect','direct')
    highlight(F(i),ego,'NodeColor',[0 0.75 0])
    highlight(F(i),neigh,'NodeColor','red')
    highlight(F(i),pre_nodes,ego,'EdgeColor','red')
    highlight(F(i),ego,suc_nodes,'EdgeColor','green')
    title(sprintf('Ego Network %d ',i))
    saveas(F(i),sprintf('Ego Network %d.png',i))
    end
    
    end
end


%% Compute n-Dimension Simplices for each Ego Network

for e = 1:numel(egonet)
    if isempty(egonet(e).edges) ~= 1
    
    egonet(e).data_0_dimnum = numnodes(egonet(e).G);

    for i = 1:n_dim
        egonet(e).data(i).dim = zeros(1,i+1);
        for j = 1:egonet(e).data_0_dimnum
            
            pre_nodes = predecessors(egonet(e).G,j);
            suc_nodes = successors(egonet(e).G,j);
            neigh = unique([pre_nodes;suc_nodes]);
            
            if i == 1
                d = size(egonet(e).edges,1);
            else
                d = egonet(e).data(i-1).dim_numsimplex;
            end
            
            for k = 1:d
                
                if i == 1
                    out = egonet(e).edges(k,1:i);
                else
                    out = egonet(e).data(i-1).dim(k,1:i);
                end
                
                if sum(out == neigh,'all') == i
                    
                    v_plex = sort([out j]);
                    
                        if ismember(v_plex,egonet(e).data(i).dim,'row') == 0
                        
                        egonet(e).data(i).dim = [egonet(e).data(i).dim;v_plex];
                        
                        d_idx = size(egonet(e).data(i).dim,1)-1;

% These two lines of code used to see what the algrorithm doing to find the
% simplex:
%                         egonet(e).data(i).simplex_details(d_idx).mainnodes = j;
%                         egonet(e).data(i).simplex_details(d_idx).v_plex = out;

%*These lines of code with * used to find all prenodes and succceded nodes of
%*the ego node
%*                        Mpre = [];
%*                        Msuc = [];

                        W = [];
                        for ck = 1:numel(out)
                            vp = [];
                            vs = [];
                            if ismember(out(ck),pre_nodes) == 1
                                wp = egonet(e).G.Edges.Weight(findedge(egonet(e).G,out(ck),j));
                                vp = [out(ck) j wp];
%*                                 Mpre = [Mpre;vp];
                            end
                            if ismember(out(ck),suc_nodes) == 1
                                ws = egonet(e).G.Edges.Weight(findedge(egonet(e).G,j,out(ck)));
                                vs = [j out(ck) ws];
%*                                 Msuc = [Msuc;vs];
                            end
                            
                            egonet(e).data(i).simplex_details(d_idx).bynodes_direction(ck).val = [vp;vs]; %*** This one stores results in the direction of the simplex
                            V = [vp;vs];
                            W = [W;V];
                            
                        end
                        
                        if i == 1
                            egonet(e).data(i).simplex_details(d_idx).plex_maxwt = max(W(:,3));
                        else
                            egonet(e).data(i).simplex_details(d_idx).bynodes_direction = [egonet(e).data(i).simplex_details(d_idx).bynodes_direction,egonet(e).data(i-1).simplex_details(k).bynodes_direction]; %*** This one stores results in the direction of the simplex
                            egonet(e).data(i).simplex_details(d_idx).plex_maxwt = max(max(W(:,3),egonet(e).data(i-1).simplex_details(k).plex_maxwt));
                        end
                            
%*                         egonet(e).data(i).simplex_details(d_idx).Mpre = Mpre;
%*                         egonet(e).data(i).simplex_details(d_idx).Msuc = Msuc; 
                        
                        end
                end
            end
        end
        
        egonet(e).data(i).dim(1,:) = [];
        egonet(e).data(i).dim_numsimplex = size(egonet(e).data(i).dim,1);
    end
    
    end
end



