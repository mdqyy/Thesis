classdef desc_feaset<handle
%DESC_FEASET Dense samling class for many types of descriptors.
%   obj = desc_feaset(type,desc_param) prepares for dense sampling.
%   type is the descriptor name. Currently, following descriptors can be
%   extracted.
%       SIFT (vl_dsift.m)
%       CSFIT (colorDescriptor)
%       RGBSIFT (colorDescriptor)
%       OpponentSIFT (colorDescriptor)
%       LBP (lbpdescriptor.m)
%       SSIM (densessim.m)
%       GIST (densegist.m)
%       ColorMeanVar (colormeanvar.m)
%   If desc_param is not available, we use following default parameters.
%       common to all descriptors
%           gridspacing = 6
%       GIST
%           ssize = 4
%           mwidth = [4 6 9 12 16]
%           orientationsPerScale = [8 8 4]
%           imageSize = 320
%       SIFT
%           patchSize = [16 25 36 49 64]
%           maxImSize = 500
%           nrml_threshold = 1
%       CSFIT
%           patchSize = [16 25 36 49 64]
%           tmp_dir = '/tmp/'
%       RGBSIFT
%           patchSize = [16 25 36 49 64]
%           tmp_dir = '/tmp/'
%       OpponentSIFT
%           patchSize = [16 25 36 49 64]
%           tmp_dir = '/tmp/'
%       LBP
%           patchSize = [16 25 36 49 64]
%           cellnum = 4
%       SSIM
%           patchSize = [3 5 7 9 11]
%           windowradius = patchSize*8
%           rinterval = 4
%           tinterval = 20
%           autovarr = 1
%           salthresh = 0
%       ColorMeanVar
%           patchSize = [16 25 36 49 64]
%
%   To extract descriptors from an image, use DESC_FEASET.extract().
%
%   See also DESC_FEASET/EXTRACT. 

%   Written by Y. Ushiku
%   Jul. 17, 2012, ISI, UT

    properties(Access=private)
        gridspacing
        type
        desc_param
        vlfeat_path = fullfile([pwd '/../imagefeature/vlfeat-0.9.14/toolbox']);
        cdesc_path =  fullfile([pwd '/../imagefeature/colordescriptors21/x86_64-linux-gcc']);
    end

    methods
        function obj = desc_feaset( type, desc_param )
            if nargin < 2
                desc_param = struct;
            end
            if isfield(desc_param,'gridspacing')
                obj.gridspacing = desc_param.gridspacing;
            else
                obj.gridspacing = 6;
            end
            obj.type = type;

            %% GIST
            if strcmpi(type,'GIST')
                if ~isfield(desc_param,'ssize')
                    desc_param.ssize = 4;
                end
                if ~isfield(desc_param,'mwidth')
                    desc_param.mwidth = [4 6 9 12 16];
                end
                if ~isfield(desc_param,'orientationsPerScale')
                    desc_param.orientationsPerScale = [8 8 4];
                end
                if ~isfield(desc_param,'imageSize')
                    desc_param.imageSize = 320;
                end
            end

            %% SIFT
            if strcmpi(type,'SIFT')
                if ~isfield(desc_param,'patchSize')
                    desc_param.patchSize = [16 25 36 49 64];
                end
                if ~isfield(desc_param,'nrml_threshold')
                    desc_param.nrml_threshold = 1;
                end
                % path
%                addpath(obj.vlfeat_path);
%                vl_setup;
            end

            %% CSIFT
            %% RGBSIFT
            %% OpponentSIFT
            if strcmpi(type,'CSIFT') || strcmpi(type,'RGBSIFT') || strcmpi(type,'OpponentSIFT')
                if ~isfield(desc_param,'patchSize')
                    desc_param.patchSize = [16 25 36 49 64];
                end
                if ~isfield(desc_param,'tmp_dir')
                    desc_param.tmp_dir = '/tmp/';
                end
            end

            %% LBP
            if strcmpi(type,'LBP')
                if ~isfield(desc_param,'patchSize')
                    desc_param.patchSize = [16 25 36 49 64];
                end
                if ~isfield(desc_param,'cellnum')
                    desc_param.cellnum = 4;
                end
            end

            %% SSIM
            if strcmpi(type,'SSIM')
                if ~isfield(desc_param,'patchSize')
                    desc_param.patchSize = [3 5 7 9 11];
                end
                if ~isfield(desc_param,'windowradius')
                    desc_param.windowradius = desc_param.patchSize*8;
                end
                if ~isfield(desc_param,'rinterval')
                    desc_param.rinterval = 4;
                end
                if ~isfield(desc_param,'tinterval')
                    desc_param.tinterval = 20;
                end
                if ~isfield(desc_param,'autovarr')
                    desc_param.autovarr = 1;
                end
                if ~isfield(desc_param,'salthresh')
                    desc_param.salthresh = 0;
                end
            end

            %% ColorMeanVar
            if strcmpi(type,'ColorMeanVar')
                if ~isfield(desc_param,'patchSize')
                    desc_param.patchSize = [16 25 36 49 64];
                end
            end
            
            obj.desc_param = desc_param;
        end        
    end
    
    methods(Static)
        function type = selectdesc()
            typenames = {'GIST', ...
                         'SIFT', ...
                         'CSIFT', ...
                         'RGBSIFT', ...
                         'OpponentSIFT', ...
                         'LBP', ...
                         'SSIM', ...
                         'ColorMeanVar'};
            disp('Select the type of descriptor you need.')
            for ind = 1:length(typenames)
                disp(['    ' num2str(ind) ':' typenames{ind}]);
            end
            while true
                typenum = input('Input the number:');
                fprintf('\n');
                disp(['Your selection is ' typenames{typenum} '.']);
                isok = input('Input just ENTER if it''s OK:');
                if isempty(isok)
                    type = typenames{typenum};
                    break;
                end
            end
        end
    end
    
end

