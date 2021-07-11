from PyQt5 import QtCore, QtGui, QtWidgets
import numpy as np
import helper
import call_matlab

class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(1500, 1500)

        self.num_verts = 3

        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        self.polygonView = QtWidgets.QGraphicsView(self.centralwidget)
        self.polygonView.setGeometry(QtCore.QRect(20, 40, 800, 800))
        self.polygonView.setObjectName("PolygonView")
        self.polygonScene = QtWidgets.QGraphicsScene(self.polygonView)

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

        self.initPolygon()

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "MainWindow"))
        self.button_add_vert.setText(_translate("MainWindow", "add a vertex"))
        self.button_delete_vert.setText(_translate("MainWindow", "delete a vertex"))

    def initPolygon(self):
        file_id = call_matlab.init_poly(self.num_verts)
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
