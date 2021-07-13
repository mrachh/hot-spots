classdef test < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure  matlab.ui.Figure
        UIAxes    matlab.ui.control.UIAxes
        usr_poly
        btn       matlab.ui.control.Button  
        chunkie_handle
        chnkr
        cparams
        pref
        edgevals
        round_sldr        matlab.ui.control.Slider   
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button down function: UIAxes
        function UIAxesButtonDown(app, event) 
            app.usr_poly
            if (isempty(app.usr_poly.Position))
            app.usr_poly = drawpolygon(app.UIAxes);
            addlistener(app.usr_poly,'MovingROI',@app.allevents_poly);
            addlistener(app.usr_poly,'ROIMoved',@app.allevents_poly);
            addlistener(app.usr_poly,'DeletingROI',@app.allevents_poly);
            verts = app.usr_poly.Position';
           
            
            app.chnkr = chunkerpoly(verts,app.cparams,app.pref,app.edgevals)
            app.chnkr
            app.usr_poly
            uiax = app.UIAxes;
            %poly_tmp = app.usr_poly;
            
            app.chunkie_handle = plot_new(uiax,app.chnkr);
            %app.usr_poly = poly_tmp;
            app.usr_poly.EdgeAlpha = 1;
            app.usr_poly.FaceAlpha = 0;
            app.usr_poly.LineWidth  = 0.01;
%            app.usr_poly = drawpolygon(app.UIAxes,'Position',poly_tmp.Position);
            
            end
            %app.usr_poly.Position
        end
        
        function deleteButtonPushed(app,btn)
            disp(['button pushed']);
            cla(app.UIAxes);
            app.usr_poly = images.roi.Polygon();
        end
        
        
        function allevents_poly(app,src,evt)
        evname = evt.EventName;
        switch(evname)
        case{'MovingROI'}
            disp(['ROI moving Previous Position: ' mat2str(evt.PreviousPosition)]);
            disp(['ROI moving Current Position: ' mat2str(evt.CurrentPosition)]);
            
%%%% now update the chunkie
            delete(app.chunkie_handle);
            verts = app.usr_poly.Position';
            app.chnkr = chunkerpoly(verts,app.cparams,app.pref,app.edgevals);
            app.chnkr
            app.usr_poly
            uiax = app.UIAxes;
            %poly_tmp = app.usr_poly;
            
            app.chunkie_handle = plot_new(uiax,app.chnkr);
            
            
        case{'ROIMoved'}
            disp(['ROI moved Previous Position: ' mat2str(evt.PreviousPosition)]);
            disp(['ROI moved Current Position: ' mat2str(evt.CurrentPosition)]);
         case{'DeletingROI'}
             disp(['ROI deleted']);
             app.chnkr    = chunker();
             app.usr_poly = images.roi.Polygon();
        end
    end
    
    function update_round(app,sld)
        app.cparams.autowidthsfac = sld.Value;
        app.cparams.autowidthsfac
        app.chnkr
        if ((app.chnkr.nch)~=0)
            disp(['here']);
            delete(app.chunkie_handle);
            verts = app.usr_poly.Position';
            app.chnkr = chunkerpoly(verts,app.cparams,app.pref,app.edgevals);
            app.chnkr
            app.usr_poly
            uiax = app.UIAxes;
            %poly_tmp = app.usr_poly;
            
            app.chunkie_handle = plot_new(uiax,app.chnkr);
        end
    end
        
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off','NextPlot','add');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            xlabel(app.UIAxes, 'x')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.ButtonDownFcn = createCallbackFcn(app, @UIAxesButtonDown, true);
            app.UIAxes.Position = [115 122 361 255];
            app.UIAxes.NextPlot = 'add';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
            
            app.btn = uibutton(app.UIFigure,'push',...
               'Text','Delete Polygon','Position',[120, 58, 100, 22],...
               'ButtonPushedFcn', @(btn,event) deleteButtonPushed(app,btn));
         
            app.round_sldr = uislider(app.UIFigure,...
                'Position',[250 78 200 3],'Value',0.1,'Limits',[0.01,0.49999],...
                'ValueChangedFcn',@(sld,event) update_round(app,sld));
          
            app.usr_poly = images.roi.Polygon();
            app.chnkr = chunker();
            app.chunkie_handle = [];
            app.cparams = struct();
            app.cparams.rounded = true;
            app.pref    = struct();
            app.pref.k  = 16;
            app.edgevals = [];
            
            
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dumb_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
© 2021 GitHub, Inc.
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
Loading complete{"mode":"full","isActive":false}