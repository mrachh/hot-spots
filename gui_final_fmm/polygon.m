classdef polygon < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        % matlab.ui.*
        UIFigure             matlab.ui.Figure
        RoundSlider          matlab.ui.control.Slider
        RoundSliderLabel     matlab.ui.control.Label
        DeletePolygonButton  matlab.ui.control.Button
        wavenumberSlider     matlab.ui.control.Slider
        wavenumberLabel      matlab.ui.control.Label
        directionKnob        matlab.ui.control.Knob
        directionKnobLabel   matlab.ui.control.Label
        UIAxes               matlab.ui.control.UIAxes
        imReSwitch           matlab.ui.control.RockerSwitch
        uOptionsButtonGroup  matlab.ui.container.ButtonGroup
        utotButton           matlab.ui.control.RadioButton
        uscatButton          matlab.ui.control.RadioButton
        uinButton            matlab.ui.control.RadioButton
        uOptionsButtonGroup2  matlab.ui.container.ButtonGroup
        ureButton           matlab.ui.control.RadioButton
        uimButton          matlab.ui.control.RadioButton
        ulgButton            matlab.ui.control.RadioButton
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        usr_poly             images.roi.Polygon
        chunkie_handle
        chnkr
        cparams
        pref
        edgevals
        sol
        F
        invtype
        imre
        out0
        direction
        zk
        dir_handle
        default_ui_name
        default_ui_position
        small_ui_position
        plot_option
        rhs
        targets
        targ_flag
        targ_corr
        xxtarg
        yytarg
        uscat
        default_font
        refopts
    end

    % Callbacks that handle component events
    methods (Access = private)
%%%%%%%%% Callback %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Value changed function: imReSwitch
        function imReSwitchChanged(app, event)
            value = app.imReSwitch.Value;
            app.imre = value;
            make_dir_plot(app);
        end
        function pltOptionsChanged(app, event)
            selectedButton = app.uOptionsButtonGroup2.SelectedObject;
            app.imre = selectedButton.Text;
            make_dir_plot(app);
        end
        % Selection changed function: uOptionsButtonGroup
        function uOptionsChanged(app, event)
            selectedButton = app.uOptionsButtonGroup.SelectedObject;
            app.plot_option = selectedButton.Text;
            make_dir_plot(app);
        end

        % Button down function: UIAxes
        function UIAxesButtonDown(app, event) 
            if (isempty(app.usr_poly.Position))
            app.usr_poly = drawpolygon(app.UIAxes);
            addlistener(app.usr_poly,'MovingROI',@app.allevents_poly);
            addlistener(app.usr_poly,'ROIMoved',@app.allevents_poly);
            addlistener(app.usr_poly,'DeletingROI',@app.allevents_poly);
            verts = app.usr_poly.Position';
            % preprocess vertices
            verts = preproc_verts(verts);
            app.usr_poly.Position = verts';
            verts0 = load('verts0.mat');
            verts = verts0.vert_coords;
            app.usr_poly.Position = verts'
            app.chnkr = chunkerpoly(verts,app.cparams,app.pref,app.edgevals);
            %app.chnkr = app.chnkr.refine(app.refopts);
            uiax = app.UIAxes;
            app.chunkie_handle = plot_new(uiax,app.chnkr);
            show_buttons(app);
            update_out(app);
            update_corr_flag(app);
            update_rhs(app);
            update_F(app);
            update_sol(app);
            update_uscat(app);
            make_dir_plot(app);
            app.chunkie_handle
            app.usr_poly.EdgeAlpha = 1;
            app.usr_poly.FaceAlpha = 0;
            app.usr_poly.LineWidth  = 0.01;
            end
        end

        % Value changed function: directionKnob
        function directionKnobTurned(app, event)
            value = -app.directionKnob.Value + 180;
            app.direction = value * 2.0 * pi / 360.0;
            update_rhs(app);
            update_sol(app);
            update_uscat(app);
            make_dir_plot(app);
            disp(['Direction: ' mat2str(app.direction)]);
        end

        % Button pushed function: DeletePolygonButton
        function DeletePolygonButtonPushed(app, event)
            disp(['button pushed']);
            cla(app.UIAxes);
            app.usr_poly = images.roi.Polygon();
            hide_buttons(app);
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
                % preprocess vertices
                verts = preproc_verts(verts);
                app.usr_poly.Position = verts'
%                
%   
                
                app.chnkr = chunkerpoly(verts,app.cparams,app.pref,app.edgevals);
                app.chnkr = app.chnkr.refine(app.refopts);
                app.usr_poly
                uiax = app.UIAxes;
                app.chunkie_handle = plot_new(uiax,app.chnkr);
                update_out(app);
                update_corr_flag(app);
                update_F(app);
                update_rhs(app);
                update_sol(app);
                update_uscat(app);
                make_dir_plot(app);

            end
        end

        % Value changed function: wavenumberSlider
        function wavenumberSliderSlided(app, event)
                %delete(app.chunkie_handle);
                verts = app.usr_poly.Position';
                % preprocess vertices
                %verts = preproc_verts(verts);
                %app.usr_poly.Position = verts'
%                
%   
                
          app.chnkr = chunkerpoly(verts,app.cparams,app.pref,app.edgevals);
                %app.chnkr = app.chnkr.refine(app.refopts);
            
            value = app.wavenumberSlider.Value;
            disp(['zk: ' mat2str(value)]);
            app.zk = value;
            app.refopts.maxchunklen = 4.0/abs(app.zk);
            app.chnkr = app.chnkr.refine(app.refopts);
            update_corr_flag(app);
            update_F(app);
            update_rhs(app);
            update_sol(app);
            update_uscat(app);
            make_dir_plot(app);
        end
%%%%%%%%% Computation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function update_out(app)
            disp('Targets Updated');
            app.UIFigure.Name = 'Finding Targets ...';
            app.out0 = find_targets(app.chnkr, app.targets);
            app.UIFigure.Name = app.default_ui_name;
        end
        
        function update_corr_flag(app)
            disp('Quadrature correction + near flags updated');
            app.UIFigure.Name = 'Computing quadrature correction ...';
            disp(sum(app.out0))
            disp(app.chnkr.nch)
            disp(app.zk)
            start = tic; [app.targ_flag, app.targ_corr] = ...
              get_flags_corr_fast(app.chnkr,app.zk,app.targets(:,app.out0));
            t1 = toc(start);
            fprintf('%5.2e s : time to compute near correction\n',t1);
            
        end

        function update_F(app)
            disp('F Updated');
            app.UIFigure.Name = 'Computing F ...';
            start = tic; [app.F,app.invtype] = compute_F(app.chnkr, app.zk); t1 = toc(start);
            fprintf('%5.2e s : time to compute F\n',t1);
            app.UIFigure.Name = app.default_ui_name;
        end

        function update_rhs(app)
            disp('rhs Updated');
            app.UIFigure.Name = 'Computing rhs ...';
            app.rhs = compute_rhs(app.chnkr, app.direction, app.zk);
            app.UIFigure.Name = app.default_ui_name;
        end

        function update_sol(app)
            disp('sol Updated');
            app.UIFigure.Name = 'Computing sol ...';
            app.sol = compute_sol(app.F, app.rhs,app.invtype);
            app.UIFigure.Name = app.default_ui_name;
        end

        function update_uscat(app)
            disp('uscat Updated');
            app.UIFigure.Name = 'Computing scattering field ...';
            app.uscat = compute_uscat_withcorr(app.chnkr, app.zk, ...
              app.sol, app.out0, app.targets, app.targ_flag, app.targ_corr);
            %app.uscat = compute_uscat(app.chnkr, app.zk, ...
            %  app.sol, app.out0, app.targets);
            app.UIFigure.Name = app.default_ui_name;
        end


%%%%%%%%% Plot $$%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function make_dir_plot(app)
            if ~isempty(app.uscat)
                if ~isempty(app.dir_handle)
                    delete(app.dir_handle);
                end
                app.dir_handle = plot_dir(app.UIAxes, ...
                    app.uscat, app.direction, app.zk, ...
                    app.targets, app.out0, app.xxtarg, ...
                    app.yytarg, app.plot_option, app.imre);
                disp('Plot updated');
                app.plot_option
            end
        end

%%%%%%%%% Helper functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function allevents_poly(app,src,evt)
            evname = evt.EventName;
            switch(evname)
            case{'MovingROI'}
                disp(['ROI moving Previous Position: ' mat2str(evt.PreviousPosition)]);
                disp(['ROI moving Current Position: ' mat2str(evt.CurrentPosition)]);

            %%%% now update the chunkie
                delete(app.chunkie_handle);
                verts = app.usr_poly.Position';
                % % preprocess vertices
                % verts = preproc_verts(verts);
                % app.usr_poly.Position = verts'
                app.chnkr = chunkerpoly(verts,app.cparams,app.pref,app.edgevals);
                app.chnkr = app.chnkr.refine(app.refopts);
                app.usr_poly
                uiax = app.UIAxes;
                app.chunkie_handle = plot_new(uiax,app.chnkr);
                
            case{'ROIMoved'}
                show_buttons(app)
                disp(['ROI moved Previous Position: ' mat2str(evt.PreviousPosition)]);
                disp(['ROI moved Current Position: ' mat2str(evt.CurrentPosition)]);
                update_out(app);
                update_corr_flag(app);
                update_rhs(app);
                update_F(app);
                update_sol(app);
                update_uscat(app);
                make_dir_plot(app);
                
            case{'DeletingROI'}
                disp(['ROI deleted']);
                app.chnkr    = chunker();
                app.usr_poly = images.roi.Polygon();
                hide_buttons(app);
            end
        end

        function show_buttons(app)
            % shows valid options after a polygon is created
            app.UIFigure.Position(3) = app.default_ui_position(3);
            app.UIFigure.Position(4) = app.default_ui_position(4);
            app.directionKnob.Visible = 1;
            app.directionKnobLabel.Visible = 1;
            app.wavenumberSlider.Visible = 1;
            app.wavenumberLabel.Visible = 1;
            app.DeletePolygonButton.Visible = 1;
            app.RoundSlider.Visible = 1;
            app.RoundSliderLabel.Visible = 1;
            app.uOptionsButtonGroup.Visible = 1;
            app.uOptionsButtonGroup2.Visible = 1;
            %app.imReSwitch.Visible = 1;
            %app.imReSwitch.Items = {'real', 'imaginary'};
        end

        function hide_buttons(app)
            % hides valid options after a polygon is created
            app.UIFigure.Position(3) = app.small_ui_position(3);
            app.UIFigure.Position(4) = app.small_ui_position(4);
            app.directionKnob.Visible = 0;
            app.directionKnobLabel.Visible = 0;
            app.wavenumberSlider.Visible = 0;
            app.wavenumberLabel.Visible = 0;
            app.DeletePolygonButton.Visible = 0;
            app.RoundSlider.Visible = 0;
            app.RoundSliderLabel.Visible = 0;
            app.uOptionsButtonGroup.Visible = 0;
            app.uOptionsButtonGroup2.Visible = 0;
            %app.imReSwitch.Visible = 0;
            %app.imReSwitch.Items = {' ', ' '};
        end
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            app.default_font = 'SansSerif'

            % initiate targets
            disp('Targets Initiated from -3 to 3');
            XLO = -3;
            XHI = 3;
            YLO = -3;
            YHI = 3;
            NPLOT = 250;
        
            xtarg = linspace(XLO,XHI,NPLOT); 
            ytarg = linspace(YLO,YHI,NPLOT);
            [app.xxtarg,app.yytarg] = meshgrid(xtarg,ytarg);
            app.targets = zeros(2,length(app.xxtarg(:)));
            app.targets(1,:) = app.xxtarg(:); 
            app.targets(2,:) = app.yytarg(:);
            %

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off', 'NextPlot','add');
            app.default_ui_position = [100 100 640 480];
            app.small_ui_position = [100 100 400 480];
            app.UIFigure.Position = app.small_ui_position;
            app.default_ui_name = 'polygon';
            app.UIFigure.Name = app.default_ui_name;
            app.UIFigure.AutoResizeChildren = 'off'
            app.UIFigure.Resize = 'off'

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
            app.directionKnobLabel.Position = [370 148 100 22];
            app.directionKnobLabel.Text = 'direction';
            app.directionKnobLabel.FontName = app.default_font;
            app.directionKnobLabel.FontSize = 16;

            % Create directionKnob
            app.directionKnob = uiknob(app.UIFigure, 'continuous');
            app.directionKnob.Limits = [-65 245];
            app.directionKnob.MajorTicks = [90];
            app.directionKnob.MajorTickLabels = {''};
            app.directionKnob.ValueChangedFcn = createCallbackFcn(app, @directionKnobTurned, true);
            %app.directionKnob.ValueChangingFcn = createCallbackFcn(app, @directionKnobTurned, true);
            app.directionKnob.MinorTicks = [90];
            app.directionKnob.Position = [348 194 146 146];

            % Create wavenumberLabel
            app.wavenumberLabel = uilabel(app.UIFigure);
            app.wavenumberLabel.HorizontalAlignment = 'right';
            app.wavenumberLabel.Position = [509 148 100 22];
            app.wavenumberLabel.Text = {'wavenumber'; ''};
            app.wavenumberLabel.FontName = app.default_font;
            app.wavenumberLabel.FontSize = 16;

            % Create wavenumberSlider
            app.wavenumberSlider = uislider(app.UIFigure);
            app.wavenumberSlider.Orientation = 'vertical';
            app.wavenumberSlider.Limits = [10 50];
            app.wavenumberSlider.ValueChangedFcn = createCallbackFcn(app, @wavenumberSliderSlided, true);
            app.wavenumberSlider.Position = [547 194 7 168];

            % Create DeletePolygonButton
            app.DeletePolygonButton = uibutton(app.UIFigure, 'push');
            app.DeletePolygonButton.ButtonPushedFcn = createCallbackFcn(app, @DeletePolygonButtonPushed, true);
            app.DeletePolygonButton.Position = [100 94 140 33];
            app.DeletePolygonButton.Text = 'delete polygon';
            app.DeletePolygonButton.FontName = app.default_font;
            app.DeletePolygonButton.FontSize = 16;

            % Create RoundSliderLabel
            app.RoundSliderLabel = uilabel(app.UIFigure);
            app.RoundSliderLabel.HorizontalAlignment = 'right';
            app.RoundSliderLabel.Position = [317 104 60 22];
            app.RoundSliderLabel.Text = 'round';
            app.RoundSliderLabel.FontName = app.default_font;
            app.RoundSliderLabel.FontSize = 16;

            % Create RoundSlider
            app.RoundSlider = uislider(app.UIFigure);
            app.RoundSlider.Limits = [0.01 0.5];
            app.RoundSlider.ValueChangedFcn = createCallbackFcn(app, @RoundSliderSlided, true);
            app.RoundSlider.Position = [399 113 211 7];
            app.RoundSlider.Value = 0.1;

            % Create uOptionsButtonGroup
            app.uOptionsButtonGroup = uibuttongroup(app.UIFigure);
            app.uOptionsButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @uOptionsChanged, true);
            app.uOptionsButtonGroup.Position = [330 392 160 71];
            

            % Create uinButton
            app.uinButton = uiradiobutton(app.uOptionsButtonGroup);
            app.uinButton.Text = 'incoming field';
            app.uinButton.Position = [11 44 160 30];
            app.uinButton.Value = true;
            app.uinButton.FontName = app.default_font;
            app.uinButton.FontSize = 16;
            app.uOptionsButtonGroup.SelectedObject = app.uinButton;

            % Create uscatButton
            app.uscatButton = uiradiobutton(app.uOptionsButtonGroup);
            app.uscatButton.Text = 'scattered field';
            app.uscatButton.Position = [12 23 160 30];
            app.uscatButton.FontName = app.default_font;
            app.uscatButton.FontSize = 16;

            % Create utotButton
            app.utotButton = uiradiobutton(app.uOptionsButtonGroup);
            app.utotButton.Text = 'total field';
            app.utotButton.Position = [11 0 160 30];
            app.utotButton.FontName = app.default_font;
            app.utotButton.FontSize = 16;

            % Create uOptionsButtonGroup
            app.uOptionsButtonGroup2 = uibuttongroup(app.UIFigure);
            app.uOptionsButtonGroup2.SelectionChangedFcn = createCallbackFcn(app, @pltOptionsChanged, true);
            app.uOptionsButtonGroup2.Position = [500 392 130 71];
            
            % Create ureButton
            app.ureButton = uiradiobutton(app.uOptionsButtonGroup2);
            app.ureButton.Text = 'real';
            app.ureButton.Position = [11 44 160 30];
            app.ureButton.Value = true;
            app.ureButton.FontName = app.default_font;
            app.ureButton.FontSize = 16;
            app.uOptionsButtonGroup2.SelectedObject = app.ureButton;
            
            % Create uimButton
            app.uimButton = uiradiobutton(app.uOptionsButtonGroup2);
            app.uimButton.Text = 'imaginary';
            app.uimButton.Position = [12 23 160 30];
            app.uimButton.Value = false;
            app.uimButton.FontName = app.default_font;
            app.uimButton.FontSize = 16;
            app.uOptionsButtonGroup2.SelectedObject = app.uimButton;
            
            % Create ulgButton
            app.ulgButton = uiradiobutton(app.uOptionsButtonGroup2);
            app.ulgButton.Text = 'abs';
            app.ulgButton.Position = [11 0 160 30];
            app.ulgButton.Value = false;
            app.ulgButton.FontName = app.default_font;
            app.ulgButton.FontSize = 16;
            app.uOptionsButtonGroup2.SelectedObject = app.ulgButton;
            
            app.ureButton.Value = true;
            % Create imReSwitch
            %app.imReSwitch = uiswitch(app.UIFigure, 'rocker');
            %app.imReSwitch.Items = {'real', 'imaginary'};
            %app.imReSwitch.ValueChangedFcn = createCallbackFcn(app, @imReSwitchChanged, true);
            %app.imReSwitch.Position = [548 404 20 45];
            %app.imReSwitch.Value = 'real';
            %app.imReSwitch.FontName = app.default_font;
            %app.imReSwitch.FontSize = 16;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';

            % Hide some buttons until a polygon is created
            hide_buttons(app);

            % % Change font
            % temp = findobj(app.UIFigure, '-property', 'FontSize');
            % set(temp,{'FontSize'}, num2cell(18));

            % Init
            app.usr_poly = images.roi.Polygon();
            app.usr_poly.Parent = app.UIAxes;
     
            
            verts = [14,14,22,21,27,25,27,23,22,18,20,17,14,11,8,10,6,5,1,3,1,7,6,13,13];
            verts = (verts-13.5)/6;
            verts2= [1,8,7,10,15,16,21,20,22,19,27,25,31,25,27,19,22,20,21,16,15,10,7,8,1];
            verts2= (verts2-15)/6;
            verts = [verts;verts2]';
            
            app.usr_poly.Position = verts;
            addlistener(app.usr_poly,'MovingROI',@app.allevents_poly);
            addlistener(app.usr_poly,'ROIMoved',@app.allevents_poly);
            addlistener(app.usr_poly,'DeletingROI',@app.allevents_poly);
          
            app.chnkr = chunker();
            app.chunkie_handle = [];
            app.cparams = struct();
            app.cparams.rounded = true;
            app.cparams.eps = 1e-3;
            app.refopts = struct();
            app.pref    = struct();
            app.pref.k  = 16;
            app.edgevals = [];
            app.sol = [];
            app.imre = 'real';
            app.plot_option = ' ';
            app.targ_flag = [];
            app.targ_corr = [];
            app.zk = app.wavenumberSlider.Value;
            app.cparams.maxchunklen = 4.0/abs(app.zk);
            app.refopts.maxchunklen = 4.0/abs(app.zk);
            app.directionKnob.Value = 90;
            app.direction = pi/2.0;
            app.plot_option = 'incoming field';
            
           
            
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
