function lines = read_txt_lines( txtfile )

fid = fopen(txtfile,'r');

if fid > 0
    
    nlines = 0;
    
    while ~feof(fid)
        fgetl(fid);
        nlines = nlines + 1;
    end
    
    nlines = nlines - 1;
    
    fseek(fid,0,-1);
    
    lines = cell(nlines,1);
    
    for k = 1:nlines
        
        lines{k} = fgetl(fid);
        
    end
    
    fclose(fid);
    
else
    
    error('read_txt_lines: Unable to read text file');
    
end