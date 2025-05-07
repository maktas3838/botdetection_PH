import edu.stanford.math.plex4.*
import java.util.ArrayList;

%% Constructing Complex for each Ego Network

validate = [];
for e = 1:numel(egonet)
    if isempty(egonet(e).edges) ~= 1

    egonet(e).stream = api.Plex4.createExplicitSimplexStream();
    
    for i = 1:numnodes(egonet(e).G)
        egonet(e).stream.addVertex(i);
    end
    
    for i = 1:n_dim_add
        for j = 1:egonet(e).data(i).dim_numsimplex
            egonet(e).stream.addElement([egonet(e).data(i).dim(j,1:i+1)],egonet(e).data(i).simplex_details(j).plex_maxwt);
        end
    end
    
    egonet(e).stream.finalizeStream();
    validate = [validate;egonet(e).stream.validateVerbose()]
    end
end

%% Compute Betti number and Plot Barcodes

for e = 1:numel(egonet)
    if isempty(egonet(e).edges) ~= 1

    persistence = api.Plex4.getModularSimplicialAlgorithm(n_dim_betti, 2);
    egonet(e).intervals = persistence.computeIntervals(egonet(e).stream);
    
    options.filename = sprintf('Barcode - Ego Network %d ', e);
    options.max_filtration_value = L;
    options.max_dimension = n_dim_betti - 1;

    if Plot == 1
        plot_barcodes(egonet(e).intervals, options);
    end
    
    end
end
