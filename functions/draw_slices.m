function draw_slices(img,nm,zslice)
hf=figure; hf.Position=[100 100 1100 300]; hf.Color='w'; 
for i=1:length(zslice)
    subplot(1,4,i);
    imagesc(flipud(rot90(img(:,:,zslice(i))))); set(gca,'YDir','normal');  %axis off; axis equal;
    xlabel('dim 1'); ylabel('dim 2'); title(sprintf('z=%d',zslice(i))); 
end
suptitle(nm)