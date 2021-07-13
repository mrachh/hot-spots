from PyQt5 import QtCore, QtGui, QtWidgets
import numpy as np
import helper
import call_matlab

class PolygonVertItem(QtWidgets.QGraphicsPathItem):
    circle = QtGui.QPainterPath()
    circle.addEllipse(QtCore.QRectF(-5, -5, 5, 5)) 

    def __init__(self, annotation_item, index):
        super(PolygonVertItem, self).__init__()
        self.m_annotation_item = annotation_item
        self.m_index = index

        self.setPath(PolygonVertItem.circle)
        self.setBrush(QtGui.QColor("green"))
        self.setPen(QtGui.QPen(QtGui.QColor("green"), 2))
        self.setFlag(QtWidgets.QGraphicsItem.ItemIsSelectable, True)
        self.setFlag(QtWidgets.QGraphicsItem.ItemIsMovable, True)
        self.setFlag(QtWidgets.QGraphicsItem.ItemSendsGeometryChanges, True)
        self.setZValue(11)
        self.setCursor(QtGui.QCursor(QtCore.Qt.PointingHandCursor))
    
    def mouseReleaseEvent(self, event):
        self.setSelected(False)
        super(PolygonVertItem, self).mouseReleaseEvent(event)

    def itemChange(self, change, value):
        if change == QtWidgets.QGraphicsItem.ItemPositionChange and self.isEnabled():
            self.m_annotation_item.movePoint(self.m_index, value)
        return super(PolygonVertItem, self).itemChange(change, value)

# end of polygon

class PolygonAnnotation(QtWidgets.QGraphicsPolygonItem):
    def __init__(self, parent=None):
        super(PolygonAnnotation, self).__init__(parent)
        self.m_points = []
        self.setZValue(10)
        self.setPen(QtGui.QPen(QtGui.QColor("green"), 2))
        self.setAcceptHoverEvents(True)

        self.setFlag(QtWidgets.QGraphicsItem.ItemIsSelectable, True)
        self.setFlag(QtWidgets.QGraphicsItem.ItemIsMovable, True)
        self.setFlag(QtWidgets.QGraphicsItem.ItemSendsGeometryChanges, True)

        self.setCursor(QtGui.QCursor(QtCore.Qt.PointingHandCursor))

        self.m_items = []

    def number_of_points(self):
        return len(self.m_items)

    def addPoint(self, p):
        self.m_points.append(p)
        self.setPolygon(QtGui.QPolygonF(self.m_points))
        item = PolygonVertItem(self, len(self.m_points) - 1)
        self.scene().addItem(item)
        self.m_items.append(item)
        item.setPos(p)

    def removeLastPoint(self):
        if self.m_points:
            self.m_points.pop()
            self.setPolygon(QtGui.QPolygonF(self.m_points))
            it = self.m_items.pop()
            self.scene().removeItem(it)
            del it

    def movePoint(self, i, p):
        if 0 <= i < len(self.m_points):
            self.m_points[i] = self.mapFromScene(p)
            self.setPolygon(QtGui.QPolygonF(self.m_points))

    def move_item(self, index, pos):
        if 0 <= index < len(self.m_items):
            item = self.m_items[index]
            item.setEnabled(False)
            item.setPos(pos)
            item.setEnabled(True)

    def itemChange(self, change, value):
        if change == QtWidgets.QGraphicsItem.ItemPositionHasChanged:
            for i, point in enumerate(self.m_points):
                self.move_item(i, self.mapToScene(point))
        # TODO: update graph
            
        return super(PolygonAnnotation, self).itemChange(change, value)


        
class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(1500, 1500)

        self.bx, self.by, self.a = 31.3/8.0, 29.2/8.0, 80

        self.num_verts = 3
        self.vert_coords = []
        self.vert_items = {}

        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        self.polygonView = QtWidgets.QGraphicsView(self.centralwidget)
        self.polygonView.setGeometry(QtCore.QRect(20, 40, 800, 800))
        self.polygonView.setObjectName("PolygonView")

        self.button_add_vert = QtWidgets.QPushButton(self.centralwidget)
        self.button_add_vert.setGeometry(QtCore.QRect(1000, 140, 201, 41))
        self.button_add_vert.setObjectName("button_add_vert")
        self.button_add_vert.clicked.connect(self.clickedAddVert)

        self.button_delete_vert = QtWidgets.QPushButton(self.centralwidget)
        self.button_delete_vert.setGeometry(QtCore.QRect(1000, 210, 201, 41))
        self.button_delete_vert.setObjectName("button_delete_vert")
        self.button_delete_vert.clicked.connect(self.clickedDeleteVert)

        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtWidgets.QMenuBar(MainWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 952, 25))
        self.menubar.setObjectName("menubar")
        MainWindow.setMenuBar(self.menubar)
        self.statusbar = QtWidgets.QStatusBar(MainWindow)
        self.statusbar.setObjectName("statusbar")
        MainWindow.setStatusBar(self.statusbar)


        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)
        # self.polygonScene.polygon_item = PolygonAnnotation()
        self.initPolygon()



    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "MainWindow"))
        self.button_add_vert.setText(_translate("MainWindow", "add a vertex"))
        self.button_delete_vert.setText(_translate("MainWindow", "delete a vertex"))
# User defined
    def initPolygon(self):
        self.polygonScene = QtWidgets.QGraphicsScene(self.polygonView)
        self.vert_coords = helper.init_poly(self.num_verts)
        self.vert_items = {}
        #draw on gui
        self.polygon = PolygonAnnotation()
        self.polygonScene.addItem(self.polygon) 
        for i in range(self.num_verts):
            self.vert_items[i] = PolygonVertItem(self.polygon,i)
            self.polygonScene.addItem(self.vert_items[i])
            # self.polygon.movePoint(i, 
            #     helper.real2gui_linear(
            #         self.vert_coords[0][i], self.vert_coords[1][i],
            #         self.a, self.bx, self.by))
            self.vert_items[i].setPos(
                *helper.real2gui_linear(
                    self.vert_coords[0][i], self.vert_coords[1][i],
                    self.a, self.bx, self.by))
        #draw in matlab
        file_id = call_matlab.draw_poly(self.vert_coords)
        pix = QtGui.QPixmap(helper.id2name(file_id))
        item = QtWidgets.QGraphicsPixmapItem(pix)
        self.polygonScene.addItem(item)
        self.polygonView.setScene(self.polygonScene)
        helper.delete_temp_file(file_id)

    def clickedAddVert(self):
        self.num_verts += 1
        self.initPolygon()
    
    def clickedDeleteVert(self):
        self.num_verts -= 1
        self.initPolygon()





if __name__ == "__main__":
    import sys
    app = QtWidgets.QApplication(sys.argv)
    MainWindow = QtWidgets.QMainWindow()
    ui = Ui_MainWindow()
    ui.setupUi(MainWindow)
    MainWindow.show()
    sys.exit(app.exec_())
