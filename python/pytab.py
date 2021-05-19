"""
    Classes to help create latex tables

    pt.Table([0.1. 0.2, 0.3] ,  )

    pt.Table()
      .addRow( [0.1. 0.2, 0.3] )
      .setCol
      .addCol( [0.1. 0.2, 0.3])
      .addTable(table,where='right')

    Table().addRow(...) >> Table().addRow(...)

    Table()
        .add( Row(...).format("{3f}")  )
        .add( Row(...) )


    # I could simply implement the + which would rbind rows and cbind columns, it might be natural
    # the only thing will be cbinding 2 tables.


"""

class Cell:

    def __init__(self,value="",h=1,w=1,format="{}"):
        self.h=h
        self.w=w
        self.value=format.format(value)

    def __str__(self):
        return(self.value)

class Row:
    """
    a table row, it contains a list of cells
    """
    def __init__(self, values, rowend="\\\\", format="{}"):
        self.cells = [Cell(value=v, format=format) for v in values]
        self.rowend = rowend
        self.cell_sep = " & "

    def __len__(self):
        return len(self.cells)

    def toTex(self):
        return( self.cell_sep.join([str(cell.value) for cell in self.cells]) + self.rowend + "\n" )

    def setEnd(self, val):
        self.rowend = val
        return (self)

    def setCellSep(self,val):
        self.cell_sep=val

    def setEndSpace(self, val):
        self.rowend = "\\\\[{}pt]".format(val)
        return(self)

    def append(self, values, format="{}"):
        self.cells.extend( [Cell(value=v, format=format) for v in values])
        return(self)

    def __str__(self):
        return(self.toTex())


class Table:
    """
    represents a table, it contains a header description, a end of line description, a shape and a list of cells
    """
    def __init__(self,values = []):
        self.headers = []
        self.rows = []

        if len(values) > 0:
            self.addRow(v1)

    def shape(self):
        return([ len(row) for row in self.rows ])

    def ncols(self):
        return max(self.shape())

    def __len__(self):
        """ returns the number of rows """
        return( len(self.rows) )

    def setHeaders(self, headers):
        """
        sets the headers for the table
        """
        #if self.ncols()>0:
        #    assert len(headers) == self.ncols()
        self.headers = headers
        return(self)

    def addRow(self, values, rowend="\\\\", format="{}"):
        """
        adds a row to the table
        """

        self.rows.append(Row(values, rowend, format))
        return(self)

    def append(self, row):
        """ adds a row to the table """
        self.rows.append(row)
        return(self)


    def addCol(self, values, rowend="\\"):
        """
        add a column to the table
        """
        self.cells[self.shape[0]] = [Cell(value=v) for v in values]
        self.rowends[self.shape[0]] = rowend
        self.shape[0] += 1
        return(self)

    def addRule(self, segs = []):
        """
        adds rules (lines) to the table
        :param segs:
        :return:
        """
        if len(segs)>0:
            row = Row([ " \\cmidrule(lr){" + str(v[0]) + "-" + str(v[1]) + "}" for v in segs], rowend="")
            row.setCellSep(" ")
            self.rows.append(row)
        else:
            self.rows.append(Row([ " \\midrule" ], rowend=""))

        return(self)

    def merge(self, table2, below=False):
        pass

    def __and__(self, other):
        """ append another table to the right """
        pass

    def __add__(self, other):
        """ append another table uner  """
        pass

    def lastRow(self):
        return(self.rows[len(self.rows)-1])

    def toTex(self):
        """ export to tex """
        tab_str = ""


        # header of the table
        tab_str += "\\begin{tabular}{" + " ".join(self.headers) + "} \n"
        tab_str += "\\toprule \n"

        # body of the table
        for row in self.rows:
            tab_str += row.toTex()

        tab_str += "\\bottomrule \n"
        tab_str += "\\end{tabular}\n"



        return(tab_str)

    def save_to_Tex(self,filename,stand_alone=False):
        """ save the current table to tex"""
        tab_str = ""

        if stand_alone:
            tab_str += "\\documentclass[preview]{standalone} \n"
            tab_str += "\\usepackage{booktabs} \n"
            tab_str += "\\begin{document} \n"

        tab_str += self.toTex()

        if stand_alone:
            tab_str += "\\end{document} \n"

        with open(filename, 'w') as file:
            file.write(tab_str)


# v1 = [ 0.1 * x for x in range(10)]

# t1 = (Table()
#         .addRow(v1,format="{:2.2f}")
#         .addRow(v1,format="{:2.2f}"))

# print(t1.shape())
# print(t1.ncols())

# print(Row(['tmp']).toTex())
# print(Row(['tmp']).append([0.0]).toTex())

#
# t1 = (Table()
#         .addRow(['a','b','c'])
#         .addRow(v1,format="{:2.2f}")
#         .addRow(v1,format="{:2.2f}")
#         .addRule([[1,2],[3,4],[4,5]])
#         .setHeaders(['c' for _ in range(10)]))
# t1.toTex()
#
# t1 = Table().addRow(v1).addRow(v1)
# t1.toTex()


#tab = ( Table(['m1','m2','m3'],header='c')
#            .rbind( Table([1,2,3], rowend = ) ))




