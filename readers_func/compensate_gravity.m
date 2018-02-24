function [ acc_comp ] = compensate_gravity(acc_sig, orn_sig)

acc_comp = zeros(size(acc_sig));
for i = 1:min(length(acc_sig), length(orn_sig))
    acc_comp(i,:) = qRotatePoint(acc_sig(i,:)', [orn_sig(i,4),orn_sig(i,1:3)]');
    acc_comp(i,3) = acc_comp(i,3)-1;
end

end

