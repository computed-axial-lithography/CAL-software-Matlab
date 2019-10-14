function [varargout] = CONVERT_meshformat(varargin)
%CONVERT_meshformat  Convert mesh data from array to faces,vertices format or vice versa
%==========================================================================
% AUTHOR        Adam H. Aitkenhead
% CONTACT       adam.aitkenhead@christie.nhs.uk
% INSTITUTION   The Christie NHS Foundation Trust
%
% USAGE         [faces,vertices] = CONVERT_meshformat(meshXYZ)
%         or... [meshXYZ]        = CONVERT_meshformat(faces,vertices)
%
% IN/OUTPUTS    meshXYZ  - Nx3x3 array - An array defining the vertex
%                          positions for each of the N facets, with: 
%                            1 row for each facet
%                            3 cols for the x,y,z coordinates
%                            3 pages for the three vertices
%
%               vertices - Nx3 array   - A list of the x,y,z coordinates of
%                          each vertex in the mesh.
%
%               faces    - Nx3 array   - A list of the vertices used in
%                          each facet of the mesh, identified using the row
%                          number in the array vertices.
%==========================================================================

%==========================================================================
% VERSION  USER  CHANGES
% -------  ----  -------
% 100817   AHA   Original version
% 111104   AHA   Housekeeping tidy-up.
%
%----------------------------------------------------------------------------
%Copyright © 2013. Adam H. Aitkenhead. All rights reserved.
%Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
%1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
%2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in
%   the documentation and/or other materials provided with the distribution.
%3. Neither the name of the Christie NHS Foundation Trust nor the names of its contributors may be used to endorse or promote products
%   derived from this software without specific prior written permission.
%THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
%THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS 
%BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER 
%IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
%OF THE POSSIBILITY OF SUCH DAMAGE.
%==========================================================================


if nargin==2 && nargout==1

  faces  = varargin{1};
  vertex = varargin{2};
   
  meshXYZ = zeros(size(faces,1),3,3);
  for loopa = 1:size(faces,1)
    meshXYZ(loopa,:,1) = vertex(faces(loopa,1),:);
    meshXYZ(loopa,:,2) = vertex(faces(loopa,2),:);
    meshXYZ(loopa,:,3) = vertex(faces(loopa,3),:);
  end

  varargout(1) = {meshXYZ};
  
  
elseif nargin==1 && nargout==2

  meshXYZ = varargin{1};
  
  vertices = [meshXYZ(:,:,1);meshXYZ(:,:,2);meshXYZ(:,:,3)];
  vertices = unique(vertices,'rows');

  faces = zeros(size(meshXYZ,1),3);

  for loopF = 1:size(meshXYZ,1)
    for loopV = 1:3
        
      %[C,IA,vertref] = intersect(meshXYZ(loopF,:,loopV),vertices,'rows');
      %The following 3 lines are equivalent to the previous line, but are much faster:
      
      vertref = find(vertices(:,1)==meshXYZ(loopF,1,loopV));
      vertref = vertref(vertices(vertref,2)==meshXYZ(loopF,2,loopV));
      vertref = vertref(vertices(vertref,3)==meshXYZ(loopF,3,loopV));
      
      faces(loopF,loopV) = vertref;
      
    end
  end
  
  varargout(1) = {faces};
  varargout(2) = {vertices};
  
  
end


end %function
