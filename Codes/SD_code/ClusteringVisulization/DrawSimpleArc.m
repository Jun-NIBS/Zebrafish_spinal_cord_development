function DrawSimpleArc(arcStartPoint,arcEndPoint,arcCenterPoint,maxYSpan,colorVec)
% Function for arc constrained to line, so can enforce max y ratio
v1 = arcStartPoint-arcCenterPoint;
v2 = arcEndPoint-arcCenterPoint;
v3 = [0 -1;1 0]*v1;
a = linspace(0,mod(atan2(det([v1,v2]),dot(v1,v2)),2*pi));
v = v1*cos(a)+v3*sin(a);
vv = [v(1,:)+arcCenterPoint(1); v(2,:)+arcCenterPoint(2)];
ySpan = max(vv(2,:))-min(vv(2,:));
if ySpan > maxYSpan
	vv(2,:) = vv(2,1)+(vv(2,:)-vv(2,1)).*(maxYSpan/ySpan);
end
plot(vv(1,:),vv(2,:),'color',colorVec)
end