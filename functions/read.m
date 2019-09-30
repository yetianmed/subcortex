function [hdr,data]=read(filename)

machineformat='ieee-le'; 

ind=findstr(filename,'.');
if ~isempty(ind)
    fileprefix=filename(1:ind-1); 
else
    fileprefix=filename;
end

if exist(strcat(fileprefix,'.hdr'),'file') &  exist(strcat(fileprefix,'.img'),'file')
    type=0; 
    hdr_filename=strcat(fileprefix,'.hdr');
    data_filename=strcat(fileprefix,'.img'); 
elseif exist(strcat(fileprefix,'.nii'),'file')
    type=1;
    hdr_filename=strcat(fileprefix,'.nii');
    data_filename=strcat(fileprefix,'.nii');    
else
    error('File missing.\n'); 
end

    
fid=fopen(hdr_filename,'r',machineformat); 
hdr=read_hdr(fid); 
fclose(fid);
if hdr.key.sizeof_hdr~=348 
    switch machineformat
        case 'ieee-le' 
            machineformat='ieee-be'; 
        case 'ieee-be' 
            machineformat='ieee-le'; 
    end
    fid=fopen(hdr_filename,'r',machineformat); 
    hdr=read_hdr(fid);
    fclose(fid);
    if hdr.key.sizeof_hdr~=348
        error('Invalid header.\n'); 
    end
end

precision=get_precision(hdr);
% fid=fopen(data_filename,'r',machineformat);
% precision=get_precision(hdr);  
% if type==1
%     fseek(fid,double(hdr.dim.vox_offset),'bof');
% end
% raw_data=zeros(1,prod(hdr.dim.dim(2:5)),precision);
% data=zeros([hdr.dim.dim(2:5)],precision);
% raw_data=fread(fid,prod(hdr.dim.dim(2:5)),strcat('*',precision)); 
% data=squeeze(reshape(raw_data,[hdr.dim.dim(2:5)]));
% fclose(fid);

if type==1;
    of=double(hdr.dim.vox_offset);
else
    of=0; 
end

precision; 
img=memmapfile(data_filename,'offset',of,'Format',precision); 
img_cpy=img.data;
data=zeros([hdr.dim.dim(2:5)],precision);
data=squeeze(reshape(img_cpy,[hdr.dim.dim(2:5)]));
%%%%
function hdr=read_hdr(fid)

hdr.key.sizeof_hdr     = fread(fid, 1,'int32')';
hdr.key.data_type      = deblank(fread(fid,10,'*char')');
hdr.key.db_name        = deblank(fread(fid,18,'*char')');
hdr.key.extents        = fread(fid, 1,'int32')';
hdr.key.session_error  = fread(fid, 1,'int16')';
hdr.key.regular        = fread(fid, 1,'*char')';
hdr.key.dim_info       = fread(fid, 1,'*char')';

hdr.dim.dim            = fread(fid,8,'int16')';
hdr.dim.intent_p1      = fread(fid,1,'float32')';
hdr.dim.intent_p2      = fread(fid,1,'float32')';
hdr.dim.intent_p3      = fread(fid,1,'float32')';
hdr.dim.intent_code    = fread(fid,1,'int16')';
hdr.dim.datatype       = fread(fid,1,'int16')';
hdr.dim.bitpix         = fread(fid,1,'int16')';
hdr.dim.slice_start    = fread(fid,1,'int16')';
hdr.dim.pixdim         = fread(fid,8,'float32')';
hdr.dim.vox_offset     = fread(fid,1,'float32')';
hdr.dim.scl_slope      = fread(fid,1,'float32')';
hdr.dim.scl_inter      = fread(fid,1,'float32')';
hdr.dim.slice_end      = fread(fid,1,'int16')';
hdr.dim.slice_code     = fread(fid,1,'char')';
hdr.dim.xyzt_units     = fread(fid,1,'char')';
hdr.dim.cal_max        = fread(fid,1,'float32')';
hdr.dim.cal_min        = fread(fid,1,'float32')';
hdr.dim.slice_duration = fread(fid,1,'float32')';
hdr.dim.toffset        = fread(fid,1,'float32')';
hdr.dim.glmax          = fread(fid,1,'int32')';
hdr.dim.glmin          = fread(fid,1,'int32')';
   
hdr.hist.descrip       = deblank(fread(fid,80,'*char')');
hdr.hist.aux_file      = deblank(fread(fid,24,'*char')');
hdr.hist.qform_code    = fread(fid,1,'int16')';
hdr.hist.sform_code    = fread(fid,1,'int16')';
hdr.hist.quatern_b     = fread(fid,1,'float32')';
hdr.hist.quatern_c     = fread(fid,1,'float32')';
hdr.hist.quatern_d     = fread(fid,1,'float32')';
hdr.hist.qoffset_x     = fread(fid,1,'float32')';
hdr.hist.qoffset_y     = fread(fid,1,'float32')';
hdr.hist.qoffset_z     = fread(fid,1,'float32')';
hdr.hist.srow_x        = fread(fid,4,'float32')';
hdr.hist.srow_y        = fread(fid,4,'float32')';
hdr.hist.srow_z        = fread(fid,4,'float32')';
hdr.hist.intent_name   = deblank(fread(fid,16,'*char')');
hdr.hist.magic         = deblank(fread(fid,4,'*char')');
fseek(fid,253,'bof');
hdr.hist.originator    = fread(fid, 5,'int16')';

return; 

%%%%
function precision=get_precision(hdr)

switch hdr.dim.datatype
    case   1,
        precision = 'ubit1';
    case   2,
        precision = 'uint8';
    case   4,
        precision = 'int16';
    case   8,
        precision = 'int32';
    case  16,
        precision = 'single';
    case  32,
        precision = 'single';
    case  64,
        precision = 'double';
    case 128,
        precision = 'uint8';
    case 256 
        precision = 'int8';
    case 511 
        precision = 'float32';
    case 512 
        precision = 'uint16';
    case 768 
        precision = 'uint32';
    case 1024
        precision = 'int64';
    case 1280
        precision = 'uint64';
    case 1792,
        precision = 'float64';
    otherwise
        error('Unknown data precision.\n'); 
end

return;
    
