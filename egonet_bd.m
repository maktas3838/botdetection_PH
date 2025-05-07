import edu.stanford.math.plex4.*
import java.util.ArrayList;

%% Bottleneck Distance

n_ego = numel(egonet);

errlog = {};

for k  = 1:(n_dim_dist+1)
    for e = 1:n_ego
        egonet(e).intervals_dim(k).dim_minus1 = egonet(e).intervals.getIntervalsAtDimension(k-1);
        egonet(e).intervals_dim(k).matlab = cell2mat(cell(toArray(egonet(e).intervals_dim(k).dim_minus1)));
        egonet(e).intervals_dim(k).matlab_ad = egonet(e).intervals_dim(k).matlab;
        egonet(e).intervals_dim(k).numinf = 0;
        egonet(e).intervals_dim(k).int_adjusted = ArrayList;
        
        if isempty(egonet(e).intervals_dim(k).matlab) ~= 1
        
        for i = 1:length(egonet(e).intervals_dim(k).matlab)
            
            rightinf = homology.barcodes.Interval.isRightInfinite(egonet(e).intervals_dim(k).matlab(i));
            if rightinf == 1
                egonet(e).intervals_dim(k).numinf = egonet(e).intervals_dim(k).numinf + 1;
                
                leftend = homology.barcodes.Interval.getStart(egonet(e).intervals_dim(k).matlab(i));
                egonet(e).intervals_dim(k).matlab_ad(i) = homology.barcodes.Interval.makeFiniteRightOpenInterval(leftend,java.lang.Double(L));
            end
        end
        
        add(egonet(e).intervals_dim(k).int_adjusted,egonet(e).intervals_dim(k).matlab_ad(1))
        for j = 2:length(egonet(e).intervals_dim(k).matlab_ad)
            egonet(e).intervals_dim(k).int_adjusted.add(egonet(e).intervals_dim(k).matlab_ad(j))
        end
        
        else
            add(egonet(e).intervals_dim(k).int_adjusted,homology.barcodes.Interval.makeFiniteRightOpenInterval(java.lang.Double(0),java.lang.Double(0)))
        end

    end
        
    
    bottleneck_distance(k).dim_minus1 = zeros(n_ego,n_ego);
    bottleneck_distance(k).dim_minus1(bottleneck_distance(k).dim_minus1 == 0) = NaN;
    
    
    for i = 1:n_ego-1
        for j = i+1:n_ego
            
            if ((egonet(i).intervals_dim(k).numinf == egonet(j).intervals_dim(k).numinf) && (isempty(egonet(i).intervals_dim(k).matlab) ~= 1) && (isempty(egonet(j).intervals_dim(k).matlab) ~= 1))
                try
                    bottleneck_distance(k).dim_minus1(i,j) = bottleneck.BottleneckDistance.computeBottleneckDistance(egonet(i).intervals_dim(k).dim_minus1,egonet(j).intervals_dim(k).dim_minus1);
                catch
                    log = sprintf('loop number %d -> %d failed in dim %d\n',i,j,k-1);
                    errlog = vertcat(errlog,log);
                end
                
            else
                try
                    bottleneck_distance(k).dim_minus1(i,j) = bottleneck.BottleneckDistance.computeBottleneckDistance(egonet(i).intervals_dim(k).int_adjusted,egonet(j).intervals_dim(k).int_adjusted);
                catch
                    log = sprintf('loop number %d -> %d failed in dim %d, adjusted interval\n',i,j,k-1);
                    errlog = vertcat(errlog,log);
                end
            end
            
        end
    end
    
    bottleneck_distance(k).dim_minus1 = triu(bottleneck_distance(k).dim_minus1) + triu(bottleneck_distance(k).dim_minus1,1)';
    bottleneck_distance(k).dim_minus1(1:n_ego+1:end) = 0;
end

%%%

bottleneck_distance_combined = zeros(n_ego,n_ego);
bottleneck_distance_combined(bottleneck_distance_combined == 0) = NaN;
for i = 1:n_ego-1
    for j = i+1:n_ego
        
        p_vec = [];
        for k = 1:(n_dim_dist+1)
            p_vec = [p_vec;bottleneck_distance(k).dim_minus1(i,j)];
        end
        p_dist = nthroot(sum(power(p_vec,n_dim_dist+1)),n_dim_dist+1);
        bottleneck_distance_combined(i,j) = p_dist;
    
    end
end

bottleneck_distance_combined = triu(bottleneck_distance_combined)+triu(bottleneck_distance_combined,1)';
bottleneck_distance_combined(1:n_ego+1:end) = 0;


