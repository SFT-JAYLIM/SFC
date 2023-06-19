function Link = calculate_ColorGrid(IterationImpactPosData, IterationCRI, ColliJointList, Link)

IterationImpactPosCount = size(IterationImpactPosData, 1);
% Link Iteration
for i = 0:size(Link, 2) - 1
    ColliJointDistance = i - ColliJointList;
    PatchRowCount = size(Link{i + 1}.Vertice(:,1:3), 1);
    
    % Link�� �� Patch�� ImpactPos������ �����Ÿ�
    % ColliPoint Iteration
    LinkOriginToImpactPosNorm = zeros(PatchRowCount, IterationImpactPosCount);
    for j = 1:IterationImpactPosCount
        LinkOriginToImpactPos = (Link{i + 1}.Vertice(:, 1:3) - ones(PatchRowCount, 1) * IterationImpactPosData(j, 1:3)).^2;
%         LinkOriginToImpactPosNorm(:, j) = (sum(LinkOriginToImpactPos, 2)).^0.5;
        LinkOriginToImpactPosNorm(:, j) = sum(LinkOriginToImpactPos, 2).^0.2;

        if  ColliJointList(j) ~= 6 && i == 6
            % Link�� ����� End-Effector�� ������� �ʵ��� ����ó��
            LinkOriginToImpactPosNorm(:, j) = LinkOriginToImpactPosNorm(:, j) + 100000000;
            
%         elseif ColliJointList(j) == 6 && i ~= 6
%             % End-Effector�� ����� Link�� ������� �ʵ��� ����ó��
%             LinkOriginToImpactPosNorm(:, j) = LinkOriginToImpactPosNorm(:, j) + 100000000;
            
        else
            % ����� �Ÿ��� ���� ������ ���� �� �ֵ��� ó��
            if abs(ColliJointDistance(j)) > 2
                LinkOriginToImpactPosNorm(:, j) = LinkOriginToImpactPosNorm(:, j) + 100000000;
            end
        end
    end
    
    [sorted_value, sorted_num] = sort(LinkOriginToImpactPosNorm, 2);
    NormalizeSortedValue = sorted_value.^2./repmat(sum(sorted_value.^2, 2), 1, IterationImpactPosCount);
    anal_v_closed_ratio = (1./NormalizeSortedValue).^2./repmat(sum((1./NormalizeSortedValue).^2, 2), 1, IterationImpactPosCount);
    anal_v_sorted = sorted_num(:,1:IterationImpactPosCount);
    
    force_wrt_sorted_value = reshape(IterationCRI(:, anal_v_sorted), PatchRowCount, IterationImpactPosCount);
    force_multiply_ratio = force_wrt_sorted_value .* anal_v_closed_ratio;
    Link{i+1}.color = sum(force_multiply_ratio, 2);
    
end
end
