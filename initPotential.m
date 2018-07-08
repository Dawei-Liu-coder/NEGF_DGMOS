function [ phi ] = initPotential( phi, doping, ni, Vt )
%% �Լ����� : ���γ󵵿� ���� �ʱ� ���ټ� ���� �Է��մϴ�. 
% �� �Ķ���ʹ� ������ �����ϴ�. 
% phi : �̸� ���ǵ� ���ټ� ���� ���� 
% doping : ��ġ�� ���� ���� �� 
% ni : intrinsic ���� �� 
% Vt : Thermal voltage 

%% ���ټ� �Է� 
% intrinsic�� ���Ͽ��� 0 ���� ���ټ� �Է� 

pp_index = find(doping < 0);    % p-type �� ���Ͽ� 
phi(pp_index) = -(Vt)*log(-doping(pp_index)./ni(pp_index)); % - ���ټ� �Է� 

nn_index = find(doping > 0);    % n-type �� ���Ͽ� 
phi(nn_index) = +(Vt)*log(+doping(nn_index)./ni(nn_index)); % + ���ټ� �Է� 
end
