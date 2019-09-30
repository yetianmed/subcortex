function write(hdr,data,filename); 

fid=fopen(filename,'w','native');
precision=get_precision(hdr);

hdr.dim.vox_offset=352;
hdr.hist.magic='n+1';
write_hdr(fid,hdr); 

fwrite(fid,ones(1,hdr.dim.vox_offset-ftell(fid)),'uint8');
data=data(:);
fwrite(fid,data(:),precision); 
fclose(fid);

%%%%
function write_hdr(fid,hdr)

fwrite(fid,hdr.key.sizeof_hdr(1),'int32');

pad = zeros(1, 10-length(hdr.key.data_type));
hdr.key.data_type =[hdr.key.data_type,char(pad)];
fwrite(fid,hdr.key.data_type(1:10),'uchar');

pad = zeros(1, 18-length(hdr.key.db_name));
hdr.key.db_name = [hdr.key.db_name,char(pad)];
fwrite(fid,hdr.key.db_name(1:18),'uchar');
    
fwrite(fid,hdr.key.extents(1),       'int32');
fwrite(fid,hdr.key.session_error(1), 'int16');
fwrite(fid,hdr.key.regular(1),       'uchar');
fwrite(fid,hdr.key.dim_info(1),      'uchar');
    
fwrite(fid,hdr.dim.dim(1:8),        'int16');
fwrite(fid,hdr.dim.intent_p1(1),  'float32');
fwrite(fid,hdr.dim.intent_p2(1),  'float32');
fwrite(fid,hdr.dim.intent_p3(1),  'float32');
fwrite(fid,hdr.dim.intent_code(1),  'int16');
fwrite(fid,hdr.dim.datatype(1),     'int16');
fwrite(fid,hdr.dim.bitpix(1),       'int16');
fwrite(fid,hdr.dim.slice_start(1),  'int16');
fwrite(fid,hdr.dim.pixdim(1:8),   'float32');
fwrite(fid,hdr.dim.vox_offset(1), 'float32');
fwrite(fid,hdr.dim.scl_slope(1),  'float32');
fwrite(fid,hdr.dim.scl_inter(1),  'float32');
fwrite(fid,hdr.dim.slice_end(1),    'int16');
fwrite(fid,hdr.dim.slice_code(1),   'uchar');
fwrite(fid,hdr.dim.xyzt_units(1),   'uchar');
fwrite(fid,hdr.dim.cal_max(1),    'float32');
fwrite(fid,hdr.dim.cal_min(1),    'float32');
fwrite(fid,hdr.dim.slice_duration(1), 'float32');
fwrite(fid,hdr.dim.toffset(1),    'float32');
fwrite(fid,hdr.dim.glmax(1),        'int32');
fwrite(fid,hdr.dim.glmin(1),        'int32');

pad=zeros(1,80-length(hdr.hist.descrip));
hdr.hist.descrip=[hdr.hist.descrip,char(pad)];
fwrite(fid,hdr.hist.descrip(1:80),'uchar');

pad=zeros(1,24-length(hdr.hist.aux_file));
hdr.hist.aux_file=[hdr.hist.aux_file,char(pad)];
fwrite(fid,hdr.hist.aux_file(1:24),'uchar');
    
fwrite(fid,hdr.hist.qform_code,    'int16');
fwrite(fid,hdr.hist.sform_code,    'int16');
fwrite(fid,hdr.hist.quatern_b,   'float32');
fwrite(fid,hdr.hist.quatern_c,   'float32');
fwrite(fid,hdr.hist.quatern_d,   'float32');
fwrite(fid,hdr.hist.qoffset_x,   'float32');
fwrite(fid,hdr.hist.qoffset_y,   'float32');
fwrite(fid,hdr.hist.qoffset_z,   'float32');
fwrite(fid,hdr.hist.srow_x(1:4), 'float32');
fwrite(fid,hdr.hist.srow_y(1:4), 'float32');
fwrite(fid,hdr.hist.srow_z(1:4), 'float32');

pad=zeros(1,16-length(hdr.hist.intent_name));
hdr.hist.intent_name=[hdr.hist.intent_name ,char(pad)];
fwrite(fid,hdr.hist.intent_name(1:16),'uchar');
    
pad=zeros(1,4-length(hdr.hist.magic));
hdr.hist.magic=[hdr.hist.magic,char(pad)];
fwrite(fid,hdr.hist.magic(1:4),'uchar');
    
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
        precision = 'float32';
    case  32,
        precision = 'float32';
    case  64,
        precision = 'float64';
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