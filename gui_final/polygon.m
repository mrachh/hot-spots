classdef polygon < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        RoundSlider          matlab.ui.control.Slider
        RoundSliderLabel     matlab.ui.control.Label
        DeletePolygonButton  matlab.ui.control.Button
        wavenumberSlider     matlab.ui.control.Slider
        wavenumberLabel      matlab.ui.control.Label
        directionKnob        matlab.ui.control.Knob
        directionKnobLabel   matlab.ui.control.Label
        UIAxes               matlab.ui.control.UIAxes
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        usr_poly
        chunkie_handle
        chnkr
        cparams
        pref
        edgevals
        sol
        F
        dir_handle
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button down function: UIAxes
        function UIAxesButtonDown(app, event) 
            if (isempty(app.usr_poly.Position))
            app.usr_poly = drawpolygon(app.UIAxes);
            addlistener(app.usr_poly,'MovingROI',@app.allevents_poly);
            addlistener(app.usr_poly,'ROIMoved',@app.allevents_poly);
            addlistener(app.usr_poly,'DeletingROI',@app.allevents_poly);
            verts = app.usr_poly.Position';
            app.chnkr = chunkerpoly(verts,app.cparams,app.pref,app.edgevals)
            uiax = app.UIAxes;
            app.chunkie_handle = plot_new(uiax,app.chnkr);
            app.chunkie_handle
            app.usr_poly.EdgeAlpha = 1;
            app.usr_poly.FaceAlpha = 0;
            app.usr_poly.LineWidth  = 0.01;
            end
        end

        % Value changed function: directionKnob
        function directionKnobTurned(app, event)
            value = app.directionKnob.Value;
            disp(['Direction: ' mat2str(value)]);
        end

        % Button pushed function: DeletePolygonButton
        function DeletePolygonButtonPushed(app, event)
            disp(['button pushed']);
            cla(app.UIAxes);
            app.usr_poly = images.roi.Polygon();
        end

        % Value changed function: RoundSlider
        function RoundSliderSlided(app, event)
            value = app.RoundSlider.Value;
            app.cparams.autowidthsfac = value;
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
                app.chunkie_handle = plot_new(uiax,app.chnkr);
            end
        end

        % Value changed function: wavenumberSlider
        function wavenumberSliderSlided(app, event)
            value = app.wavenumberSlider.Value;
            disp(['zk: ' mat2str(value)]);
        end

        % Helper function
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
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            % Init
            app.usr_poly = images.roi.Polygon();
            app.chnkr = chunker();
            app.chunkie_handle = [];
            app.cparams = struct();
            app.cparams.rounded = true;
            app.pref    = struct();
            app.pref.k  = 16;
            app.edgevals = [];
            app.sol = [];

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            app.UIAxes.XLim = [-3 3];
            app.UIAxes.YLim = [-3 3];
            app.UIAxes.Position = [24 139 297 263];
            app.UIAxes.ButtonDownFcn = createCallbackFcn(app, @UIAxesButtonDown, true);
            app.UIAxes.NextPlot = 'add';

            % Create directionKnobLabel
            app.directionKnobLabel = uilabel(app.UIFigure);
            app.directionKnobLabel.HorizontalAlignment = 'center';
            app.directionKnobLabel.Position = [395 178 51 22];
            app.directionKnobLabel.Text = 'direction';

            % Create directionKnob
            app.directionKnob = uiknob(app.UIFigure, 'continuous');
            app.directionKnob.Limits = [-160 160];
            app.directionKnob.MajorTicks = [-160 -120 -80 -40 0 40 80 120 160];
            app.directionKnob.MajorTickLabels = {''};
            app.directionKnob.ValueChangedFcn = createCallbackFcn(app, @directionKnobTurned, true);
            app.directionKnob.MinorTicks = [-160 -150 -140 -130 -120 -110 -100 -90 -80 -70 -60 -50 -40 -30 -20 -10 0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160];
            app.directionKnob.Position = [348 234 146 146];

            % Create wavenumberLabel
            app.wavenumberLabel = uilabel(app.UIFigure);
            app.wavenumberLabel.HorizontalAlignment = 'right';
            app.wavenumberLabel.Position = [519 178 74 22];
            app.wavenumberLabel.Text = {'wavenumber'; ''};

            % Create wavenumberSlider
            app.wavenumberSlider = uislider(app.UIFigure);
            app.wavenumberSlider.Orientation = 'vertical';
            app.wavenumberSlider.ValueChangedFcn = createCallbackFcn(app, @wavenumberSliderSlided, true);
            app.wavenumberSlider.Position = [547 234 7 168];

            % Create DeletePolygonButton
            app.DeletePolygonButton = uibutton(app.UIFigure, 'push');
            app.DeletePolygonButton.ButtonPushedFcn = createCallbackFcn(app, @DeletePolygonButtonPushed, true);
            app.DeletePolygonButton.Position = [58 94 140 33];
            app.DeletePolygonButton.Text = 'Delete Polygon';

            % Create RoundSliderLabel
            app.RoundSliderLabel = uilabel(app.UIFigure);
            app.RoundSliderLabel.HorizontalAlignment = 'right';
            app.RoundSliderLabel.Position = [257 104 41 22];
            app.RoundSliderLabel.Text = 'Round';

            % Create RoundSlider
            app.RoundSlider = uislider(app.UIFigure);
            app.RoundSlider.Limits = [0.01 0.5];
            app.RoundSlider.ValueChangedFcn = createCallbackFcn(app, @RoundSliderSlided, true);
            app.RoundSlider.Position = [319 113 211 7];
            app.RoundSlider.Value = 0.01;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = polygon

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