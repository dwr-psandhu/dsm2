from dbutil import *
from sqlquery import *
from component import *

 
INPUT_TYPE_TXT_PARENT_TABLES={
                 "grid":["channel","gate","reservoir","transfer","channel_ic","reservoir_ic"],
                 "input":["boundary_stage","boundary_flow","source_flow"]                  
                 }
                 
TXT_CHILD_TABLES={"channel":["xsect_layer"],\
                  "gate":["gate_device"],\
                  "reservoir":["reservoir_connection"]
                }
                  
SQL={"channel":channelSQL,\
               "gate":gateSQL,\
               "reservoir":reservoirSQL,\
               "transfer":transferSQL,\
               "channel_ic":channelicSQL,\
               "reservoir_ic":reservoiricSQL,\
               "input_climate":inputclimateSQL,\
               "input_transfer_flow":inputtransferflowSQL,\
               "input_gate":inputgateSQL,\
               "input_node":inputnodeSQL,\
               "boundary_stage":boundarystageSQL,\
               "boundary_flow":boundaryflowSQL,\
               "source_flow":sourceflowSQL,\
               "source_flow_reservoir":sourceflowreservoirSQL,\
               "node_concentration":nodeconcSQL,\
               "reservoir_concentration":reservoirconcSQL,\
               "output_channel":outputchannelSQL,\
               "output_reservoir":outputresSQL,\
               "output_channel_concentration":outputchannelconcSQL,\
               "output_reservoir_concentration":outputresconcSQL,\
               "output_gate":outputgateSQL,\
               "operating_rule":opruleSQL,\
               "oprule_expression":opruleexSQL,\
               "oprule_time_series":opruletsSQL,\
               "group":groupSQL,\
               "rate_coefficient":ratecoeffSQL,\
               "xsect_layer":xsectlayerSQL,
              "gate_device":gatedeviceSQL,
              "reservoir_connection":reservoirconnectionSQL,
              "group_member":groupmemberSQL}


COMPONENT_MEMBERS=component_members()


def trivial_convert(row):
    return [str(field) for field in row]

def quote_string(field):
    if (field.find(" ") >= 0): 
        return "\"%s\"" % field
    else:
        return field
    
def quote_string_convert(row):
    new_row=[str(field) for field in row]
    new_row=[quote_string(field) for field in new_row]
    
CONVERTERS={"channel_ic" : channel_ic_convert,
                             "oprule": quote_string_convert,
                             "oprule_expressions": quote_string_convert,
                             }

def convert_table(fout,tablename,layerid):
        print "Converting table: %s\n" % tablename
        sql=SQL[tablename]
        data=cur.execute(sql,layerid).fetchall()
        if not data or (len(data) ==0): 
            print "Table \"%s\" empty" % tablename
            return
        header=COMPONENT_MEMBERS[tablename]
        fout.write(tablename.upper())
        if CONVERTERS.has_key(tablename):
            converter=CONVERTERS[tablename]
        else:
            converter=trivial_convert
        headertxt=string.join(header,"        ").upper()
        fout.write("\n%s\n" % headertxt)
        for row in data:
            datastr=converter(row)
            rowtxt=string.join(datastr,"        ")
            fout.write("%s\n" % rowtxt)
        fout.write("END\n\n##\n")    


def convert_layer(db_name,cur,txt_name,group_by="parent_table"):
    """
        Takes a parent layer like 'std_delta_grid' and a text name for the layer
        like txt_name is 'delta_090304' and creates corresponding text input
        grouped in files by parent object. So if txt_name is 'delta_090304' the output files
        would be channel_delta090304.inp,  gate_delta090304.inp, etc.
    """
    component_type=get_component_type(db_name,cur)
    txt_parent_list=INPUT_TYPE_TXT_PARENT_TABLES[component_type]
    layeridSQL="SELECT layer_id FROM layer_definition WHERE name LIKE ?"    
    layerid=cur.execute(layeridSQL,db_name).fetchone()[0]
    for txt_parent in txt_parent_list:
        txt_child_list=[]
        if txt_parent in TXT_CHILD_TABLES.keys():
            txt_child_list=TXT_CHILD_TABLES[txt_parent]
        fname=txt_parent+"_"+txt_name+".inp"
        fout=open(fname,"w")
        convert_table(fout,txt_parent,layerid)
        for txt_child in txt_child_list:
             convert_table(fout,txt_child,layerid)
        fout.close()
        
        



        
def get_component_type(db_layer_name,cur):
    SQL="SELECT component_type FROM layer_definition WHERE name=?;"
    type=cur.execute(SQL,db_layer_name).fetchone()[0]
    return type

if __name__ == "__main__":
    dbcnn=DBConnect("dsm2input")
    cur=dbcnn.cnn.cursor()
    DB_LAYER_NAME=["std_delta_grid","delta_historical_stage"]
    for layer in DB_LAYER_NAME:
        convert_layer(layer,cur,layer)

    cur.close()
        
    

    
