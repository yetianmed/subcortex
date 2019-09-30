function mat2nii(img,file_name,varargin)
%Writes an image intensity matrix to an nii file
%Input: image matrix in either matrix or vectorized form and nii file name 
%Optional inputs: image dimensions vector, data precision and reference volume
%Image dimensions are required if image matrix is vectorized
%Default precision is 32 bits per pixel
%Precision options are: 8, 16, 32, 64 
%Header "hist" field is copied from the reference volume, otherwise a nonconforming
%"hist" field is used
%Example
%mat2nii(img,'abc.nii',[128 128 64 5],32,'volume.nii') 

if nargin==2
    dims=size(img);
    precision=32; 
    hist=0;
elseif nargin==3 
    dims=varargin{1};
    if prod(dims)~=prod(size(img))
        error('Dimension mismatch');
    end
    precision=32;
    hist=0;
elseif nargin==4
    dims=varargin{1};
    if prod(dims)~=prod(size(img))
        error('Dimension mismatch');
    end
    precision=varargin{2};
    hist=0;
elseif nargin==5
    dims=varargin{1};
    if prod(dims)~=prod(size(img))
        error('Dimension mismatch');
    end
    precision=varargin{2};
    hist=1;
    [ref_hdr,ref_data]=read(varargin{3}); 
else
    error('Too many or to few input arguments');  
end

if precision==8 
    mat_class='uint8'; 
    nii_datatype=2; 
elseif precision==16
    mat_class='int16'; 
    nii_datatype=4; 
elseif precision==32
    mat_class='single'; 
    nii_datatype=16;  
elseif precision==64
    mat_class='double'; 
    nii_datatype=64;
else
    error('Unknown precision'); 
end
    

%Write header
%Set minimum number of fields

if hist==0
    hdr.key.sizeof_hdr=348;
    hdr.key.data_type=' ';
    hdr.key.db_name=' ';    
    hdr.key.extents=0;
    hdr.key.session_error=0;
    hdr.key.regular='r';
    hdr.key.dim_info=' ';

    hdr.dim.dim=ones(1,8);
    hdr.dim.dim(1)=length(dims);
    hdr.dim.dim(2:length(dims)+1)=dims; 
    hdr.dim.intent_p1=0;
    hdr.dim.intent_p2=0;
    hdr.dim.intent_p3=0;
    hdr.dim.intent_code=0;
    hdr.dim.datatype=nii_datatype;
    hdr.dim.bitpix=precision; 
    hdr.dim.slice_start=0;
    hdr.dim.pixdim=[-1 2 2 2 0 0 0 0];
    hdr.dim.vox_offset=352;
    hdr.dim.scl_slope=0;
    hdr.dim.scl_inter=0;
    hdr.dim.slice_end=0;
    hdr.dim.slice_code=0;
    hdr.dim.xyzt_units=1;
    hdr.dim.cal_max=0;
    hdr.dim.cal_min=0;
    hdr.dim.slice_duration=0;
    hdr.dim.toffset=0;
    hdr.dim.glmax=0;
    hdr.dim.glmin=0;

    hdr.hist.descrip='nonconforming header';
    hdr.hist.aux_file=' ';
    hdr.hist.qform_code=0;
    hdr.hist.sform_code=0;
    hdr.hist.quatern_b=0;
    hdr.hist.quatern_c=1;
    hdr.hist.quatern_d=0;
    hdr.hist.qoffset_x=0;
    hdr.hist.qoffset_y=0;
    hdr.hist.qoffset_z=0;
    hdr.hist.srow_x=[1 0 0 0];
    hdr.hist.srow_y=[0 1 0 0];
    hdr.hist.srow_z=[0 0 1 0];
    hdr.hist.intent_name=' ';
    hdr.hist.magic='n+1';
    hdr.hist.originator=[0 0 0 0 0];
else
    hdr=ref_hdr;
    hdr.dim.datatype=nii_datatype;
    hdr.dim.bitpix=precision;
    hdr.dim.dim=ones(1,8);
    hdr.dim.dim(1)=length(dims);
    hdr.dim.dim(2:length(dims)+1)=dims; 
end

write(hdr,img(:),file_name); 